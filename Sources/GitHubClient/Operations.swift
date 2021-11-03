import Foundation

extension RepoName {
    
    // Fetch latest's release
    // https://docs.github.com/en/rest/reference/repos#get-the-latest-release
    var latestRelease: Request<GithubRelease> {
        Request(path: "/repos/\(owner)/\(name)/releases/latest")
    }
}

