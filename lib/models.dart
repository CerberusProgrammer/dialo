abstract class Node {
  String id;
  String description;

  Node({required this.id, required this.description});

  void validate() {
    if (id.isEmpty) {
      throw Exception("Node ID cannot be empty.");
    }
    if (description.isEmpty) {
      throw Exception("Node description cannot be empty.");
    }
  }
}

class Event extends Node {
  String text;
  String character;
  List<Node> nodes;

  Event({
    required super.id,
    required super.description,
    required this.text,
    required this.character,
    required this.nodes,
  });

  @override
  void validate() {
    super.validate();
    if (text.isEmpty) {
      throw Exception("Event text cannot be empty.");
    }
    if (character.isEmpty) {
      throw Exception("Event character cannot be empty.");
    }
  }
}

class Condition extends Node {
  String condition;
  String operator;
  String equivalence;
  String type;
  Node? trueNode;
  Node? falseNode;

  Condition({
    required super.id,
    required super.description,
    required this.condition,
    required this.operator,
    required this.equivalence,
    required this.type,
    this.trueNode,
    this.falseNode,
  });

  @override
  void validate() {
    super.validate();
    if (condition.isEmpty) {
      throw Exception("Condition cannot be empty.");
    }
    if (operator.isEmpty) {
      throw Exception("Operator cannot be empty.");
    }
    if (equivalence.isEmpty) {
      throw Exception("Equivalence cannot be empty.");
    }
    if (type.isEmpty) {
      throw Exception("Type cannot be empty.");
    }
  }
}

class Action extends Node {
  String name;
  String type;
  String character;
  Node? node;

  Action({
    required super.id,
    required super.description,
    required this.name,
    required this.type,
    required this.character,
    this.node,
  });

  @override
  void validate() {
    super.validate();
    if (name.isEmpty) {
      throw Exception("Action name cannot be empty.");
    }
    if (type.isEmpty) {
      throw Exception("Action type cannot be empty.");
    }
    if (character.isEmpty) {
      throw Exception("Action character cannot be empty.");
    }
  }
}

class Transition extends Node {
  String name;
  Node? destinationNode;
  Scene? destinationScene;

  Transition({
    required super.id,
    required super.description,
    required this.name,
    this.destinationNode,
    this.destinationScene,
  });

  @override
  void validate() {
    super.validate();
    if (name.isEmpty) {
      throw Exception("Transition name cannot be empty.");
    }
  }
}

class Dialogue extends Node {
  String text;
  String character;
  String sentiment;
  Node? dialogueNode;
  Node? eventNode;

  Dialogue({
    required super.id,
    required super.description,
    required this.text,
    required this.character,
    required this.sentiment,
    this.dialogueNode,
    this.eventNode,
  });

  @override
  void validate() {
    super.validate();
    if (text.isEmpty) {
      throw Exception("Dialogue text cannot be empty.");
    }
    if (character.isEmpty) {
      throw Exception("Dialogue character cannot be empty.");
    }
    if (sentiment.isEmpty) {
      throw Exception("Dialogue sentiment cannot be empty.");
    }
  }
}

class Scene {
  String id;
  String name;
  List<Node> nodes;

  Scene({
    required this.id,
    required this.name,
    required this.nodes,
  });

  void validate() {
    if (id.isEmpty) {
      throw Exception("Scene ID cannot be empty.");
    }
    if (name.isEmpty) {
      throw Exception("Scene name cannot be empty.");
    }
  }
}

class Campaign {
  String id;
  String name;
  List<Scene> scenes;

  Campaign({
    required this.id,
    required this.name,
    required this.scenes,
  });

  void validate() {
    if (id.isEmpty) {
      throw Exception("Campaign ID cannot be empty.");
    }
    if (name.isEmpty) {
      throw Exception("Campaign name cannot be empty.");
    }
  }
}

class NodeManager {
  bool linkNode(Node origin, Node destination) {
    if (origin is Dialogue) {
      if (destination is Dialogue || destination is Event) {
        origin.dialogueNode = destination;
        return true;
      }
    } else if (origin is Event) {
      origin.nodes.add(destination);
      return true;
    } else if (origin is Condition) {
      if (origin.trueNode == null) {
        origin.trueNode = destination;
        return true;
      } else if (origin.falseNode == null) {
        origin.falseNode = destination;
        return true;
      }
    } else if (origin is Action) {
      origin.node = destination;
      return true;
    } else if (origin is Transition) {
      origin.destinationNode = destination;
      return true;
    }
    return false;
  }

  bool unlinkNode(Node origin, Node destination) {
    if (origin is Dialogue) {
      if (origin.dialogueNode == destination) {
        origin.dialogueNode = null;
        return true;
      } else if (origin.eventNode == destination) {
        origin.eventNode = null;
        return true;
      }
    } else if (origin is Event) {
      return origin.nodes.remove(destination);
    } else if (origin is Condition) {
      if (origin.trueNode == destination) {
        origin.trueNode = null;
        return true;
      } else if (origin.falseNode == destination) {
        origin.falseNode = null;
        return true;
      }
    } else if (origin is Action) {
      if (origin.node == destination) {
        origin.node = null;
        return true;
      }
    } else if (origin is Transition) {
      if (origin.destinationNode == destination) {
        origin.destinationNode = null;
        return true;
      }
    }
    return false;
  }
}
