# HOWTO

Guide on how to do common tasks on this website.

## Table of Contents

1. Guidelines
    - [Create a branch when making a change](#create-a-branch-when-making-a-change)
    - [Create a Pull Request and get reviews](#create-a-pull-request-and-get-reviews)
    - [Where to edit files](#where-to-edit-files)
    - [Changes are automatically deployed when merged](#changes-are-automatically-deployed-when-merged)
2. Tasks
    - [Update the launch calendar](#update-the-launch-calendar)
    - [Post a Go/No Go decision](#post-a-go-no-go-decision)
    - [Upload photos from a launch](#upload-photos-from-a-launch)
---

## Guidelines
Here are some general guidelines to follow when making changes.

### Create a branch when making a change
The website is published from the `main` branch, which is considered "production". The `main` branch 
is the only "long-lived" permanent branch, and should generally be used to create small fix or feature 
branches. Read more about Git branches [here](https://git-scm.com/book/en/v2/Git-Branching-Branches-in-a-Nutshell).

A branch allows isolation of the change while its being finalized and tested. So if you're working 
on a big change but haven't completed it yet, you can make a critical fix on a separate branch and
merge it - *without* having to worry about testing or undoing that big change.

Your first step should be to make a branch when committing any changes.

### Create a Pull Request and get reviews
Reviews make sure things look right - or at least that people understand what's going on.

Once you're done (or *nearly* done) with making changes on a branch, then you're ready to create a Pull Request
to request that the changes on that branch be merged to the `main` production branch.

A Pull Request is another name for a change request - it originated with the open source community, but
is now used for any type of request where a change is being reviewed prior to integration into the primary branch.

Once the changes are reviewed and merged, the Pull Request can be merged to the `main` branch and closed, and 
the branch deleted.

### Where to edit files
Small, simple changes to a few files can be easily made through the GitHub.com web interface.  First, find the file
you want to edit.  Then click the 'Edit' button (pencil) to make changes to the file in-line.  When done, click the 
`Commit Changes` button and create a new branch.  Giving the branch a name like `add-vendor-links` helps you and others
keep track of the branch intent.

Larger changes - such as moving files around - requires more testing and experimentation.  You'll want to clone the
repository to your local computer, make changes, test them out, then finally commit them.  You can use `GitHub Desktop`
to do the clone - download it [here](https://desktop.github.com/).  For making the changes, Microsoft VSCode is a free
and popular editor - you can download it [here](https://code.visualstudio.com/download).

Testing the website locally can be accomplished by installing Ruby and the Jekyll package for Ruby.  See the 
[GitHub docs](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekylltesting-your-github-pages-site-locally-with-jekyll#building-your-site-locally)
on how to build and test using Jekyll locally.

### Changes are automatically deployed when merged
When changes are merged to the `main` branch, the GitHub Actions workflow automatically kicks in and uploads / updates the
website.  You can see the progress of the upload via the `Actions` tab under this repository. The job takes about 15 minutes
to complete.

---

## Update the launch calendar
The Launch Schedule is present on the main page as its the one used most frequently.

### Steps
1. Navigate to [`_pages/index.md`](_pages/index.md) page and edit it.
2. Update the MarkDown table dates.  You can read more about GitHub Markdown Tables [here](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/organizing-information-with-tables).
   Use a [MarkDown table generator](https://www.tablesgenerator.com/markdown_tables) if its anything complicated.
3. Commit the changes to a new branch and create a Pull Request.  If it's urgent, merge the Pull Request right away without waiting for a review.

## Posting a Go/No Go decision
This information should be posted on the main page in two places:
 1. In the Launch Schedule status window - GO / NO GO
 2. As a notification above the Launch Schedule.

### Steps
1. Navigate to [`_pages/index.md`](_pages/index.md) page and edit it.
2. Update the MarkDown table dates.  You can read more about GitHub Markdown Tables [here](https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/organizing-information-with-tables).
   Use a [MarkDown table generator](https://www.tablesgenerator.com/markdown_tables) if its anything complicated.
3. Commit the changes to a new branch and create a Pull Request.  Merge the Pull Request right away without waiting for a review.  Check the results when deployed.

## Upload photos from a launch
After a launch is complete, we like to post photos online for members to share.

### Steps
1. Clone the repository to your local computer.
   You can edit and upload files via the Web UI, but larger changes usually are much easier with a local copy.
   You can use [GitHub Desktop](https://desktop.github.com/) to clone the repository, and [VSCode](https://code.visualstudio.com/download)
   to edit text files.

2. Create a new directory under `_launch_pictures` with the date on it.
3. Copy each image and its thumbnail into the new directory.  The expected image format is `yyyy-mm-dd-index.jpg` and `yyyy-mm-dd-index_tn.jpg`.
4. Run the powershell script `TODO.ps1` to create a Markdown file in the new directory. Update the name in 
   the YAML frontmatter (first section in the file, starting and ending with `---`).
6. Create a branch via GitHub Desktop.  Add the modified image files and new MarkDown file.
7. Push the branch up to GitHub.com and create a Pull Request.
