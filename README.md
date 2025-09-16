# 🐢 Code-Turtle Reviewer

This GitHub Action provides automated, AI-powered code reviews for your pull requests. By analyzing changes and understanding the context of your code, it offers suggestions to help you improve code quality.

## 🚀 How to Use

Create a workflow file in your repository (e.g., `.github/workflows/code-turtle-reviewer.yml`) and add the following code:

```yaml
name: 'Code-Turtle Reviewer'

on:
  pull_request:
    types: [opened, reopened, synchronize]

jobs:
  code-review:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Run Review
        uses: richard-m-j/code-turtle-reviewer@v1
        with:
          github_token: ${{ secrets.ACCESS_TOKEN_GITHUB }}
          pinecone_api_key: ${{ secrets.PINECONE_API_KEY }}
          pinecone_environment: ${{ secrets.PINECONE_ENVIRONMENT }}
          serpapi_api_key: ${{ secrets.SERPAPI_API_KEY }}
          aws_access_key_id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws_secret_access_key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}