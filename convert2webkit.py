from typing import List

def generate_file_content(action_type: str, category: str) -> str:
    """Retrieve and format data for a category as a JSON-like string."""
    category_data = get_category_data(category)
    parsed_data = parse_data(category_data, action_type)
    return "[\n" + ",\n".join(parsed_data) + "\n]" if parsed_data else ""

def write_to_file(content: str, category: str, action_type: str) -> None:
    """Write content to a file named using the category and action type."""
    filename = f"{action_type}_{category}.json"
    with open(filename, "w") as file:
        file.write(content)
    print(f"Wrote content to {filename}")

def get_category_data(category: str) -> List[str]:
    #TODO(issam): Implement data retrieval based on category
    pass

def parse_data(data: List[str], action_type: str) -> List[str]:
    #TODO(issam): Implement data parsing based on category
    return data

def generate_list(action_type: str, categories: List[str]) -> None:
    """Generate files with data for each category based on the action type."""
    for category in categories:
        file_content = generate_file_content(action_type, category)
        if file_content:
            write_to_file(file_content, category, action_type)

if __name__ == "__main__":
    # List of categories for blocking and blocking cookies
    # For reference: https://developer.apple.com/documentation/safariservices/creating-a-content-blocker#Select-values-for-the-type-field
    block_categories = [ "advertising", "analytics", "social", "cryptomining", "fingerprinting", "content"]
    cookie_block_categories = ["advertising", "analytics", "social", "content"]

    generate_list("block", block_categories)
    generate_list("blockCookies", cookie_block_categories)
