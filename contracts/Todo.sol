// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.28;

contract Todo {
    struct TodoList {
        uint256 id;
        bool isDone;
        string description;
        uint256 createdAt;
    }

    event TodoAdded(uint256 indexed id, string description);
    event TodoDeleted(uint256 indexed id, string description);
    event TodoUpdated(uint256 indexed id, string description, bool isDone);
    event TodoDescriptionUpdated(
        uint256 indexed id,
        string oldDescription,
        string newDescription
    );

    mapping(uint256 => TodoList) private todos;
    uint256 public _nextId;
    // Track the number of active todos to size the array correctly
    uint256 public activeTodoCount;

    modifier todoExist(uint256 id) {
        require(todos[id].createdAt != 0, "Todo NOT FOUND");
        _;
    }

    function addItems(string calldata _description) external {
        require(bytes(_description).length > 0, "INVALID DESCRIPTION");
        uint256 id = ++_nextId;

        todos[id] = TodoList({
            id: id,
            isDone: false,
            description: _description,
            createdAt: block.timestamp
        });

        activeTodoCount++; // Increment active todo count

        emit TodoAdded(id, _description);
    }

    function deleteItems(uint256 _id) external todoExist(_id) {
        string memory todoDescription = todos[_id].description;
        delete todos[_id];
        activeTodoCount--; // Decrement active todo count instead of _nextId

        emit TodoDeleted(_id, todoDescription);
    }

    function toggleCompleted(uint256 _id) external todoExist(_id) {
        todos[_id].isDone = !todos[_id].isDone;

        emit TodoUpdated(_id, todos[_id].description, todos[_id].isDone);
    }

    function updateDescription(uint256 _id, string calldata _description)
        external
        todoExist(_id)
    {
        require(bytes(_description).length > 0, "INVALID DESCRIPTION");
        string memory oldDescription = todos[_id].description;
        todos[_id].description = _description;

        emit TodoDescriptionUpdated(_id, oldDescription, _description);
    }

    function getAllTodos() external view returns (TodoList[] memory) {
        TodoList[] memory todoArray = new TodoList[](activeTodoCount);
        uint256 index = 0;

        for (uint256 i = 1; i <= _nextId; i++) {
            if (todos[i].createdAt != 0) {
                todoArray[index] = todos[i];
                index++;
            }
        }
        return todoArray;
    }
}