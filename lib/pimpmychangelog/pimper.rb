module PimpMyChangelog

  class Pimper
    SEPARATOR = "<!--- The following link definitions are generated by PimpMyChangelog --->"

    attr_reader :user, :project, :changelog

    # @param user [String] Github user of this changelog
    # @param project [String] Github project of this changelog
    # @param changelog [String] The changelog
    def initialize(user, project, changelog)
      @user = user
      @project = project
      @changelog = changelog
    end

    # @return [String] The changelog with contributors and issues as link
    def better_changelog
      parsed_changelog = Parser.new(changelog)

      linkify_changelog(parsed_changelog.content) +
        links_definitions(parsed_changelog.issues, parsed_changelog.contributors)
    end

    protected

    # @param [String] changelog
    # @return [String] The changelog with users and issues linkified.
    #
    #   Example: "@pcreux closes issue #123"
    #   # => "[@pcreux][] closes issue [#123][]"
    def linkify_changelog(changelog)
      changelog.
        gsub(ISSUE_NUMBER_REGEXP, '\1[#\2][]\3').
        gsub(CONTRIBUTOR_REGEXP, '\1[@\2][]\3')
    end

    # The following regexp ensure that the issue or contributor is
    # not wrapped between brackets (aka: is a link)
    ISSUE_NUMBER_REGEXP = /(^|[^\[])#(\d+)($|[^\]])/
    CONTRIBUTOR_REGEXP = /(^|[^\[])@(\w+)($|[^\]])/

    # @param [Array] issues An array of issue numbers
    # @param [Array] contributors An array of contributors github ids
    #
    # @return [String] A list of link definitions
    def links_definitions(issues, contributors)
      return '' if issues.empty? && contributors.empty?

      issues_list = issues.map do |issue|
        "[##{issue}]: https://github.com/#{user}/#{project}/issues/#{issue}"
      end

      contributors_list = contributors.map do |contributor|
        "[@#{contributor}]: https://github.com/#{contributor}"
      end

      ([SEPARATOR] + issues_list + contributors_list).join("\n")
    end
  end
end
