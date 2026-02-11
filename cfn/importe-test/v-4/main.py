import json
import copy

def load_json(path):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)

def normalize_resource(resource):
    """
    Normaliza recurso para comparação.
    Remove campos que não afetam identidade real.
    """
    r = copy.deepcopy(resource)

    # remove metadados que podem variar
    r.pop("DependsOn", None)
    r.pop("Metadata", None)

    return r

def resource_exists_in_b(resource_a, resources_b):
    """
    Verifica se um recurso de A já existe em B
    comparando Type + Properties
    """
    norm_a = normalize_resource(resource_a)

    for _, resource_b in resources_b.items():
        norm_b = normalize_resource(resource_b)

        if (
            norm_a.get("Type") == norm_b.get("Type") and
            norm_a.get("Properties") == norm_b.get("Properties")
        ):
            return True

    return False

def diff_templates(json_a, json_b):
    resources_a = json_a.get("Resources", {})
    resources_b = json_b.get("Resources", {})

    result = copy.deepcopy(json_a)
    result["Resources"] = {}

    for logical_id, resource in resources_a.items():
        if not resource_exists_in_b(resource, resources_b):
            result["Resources"][logical_id] = resource

    return result


# ====== USO ======

json_a = load_json("json-a.json")
json_b = load_json("json-b.json")

json_c = diff_templates(json_a, json_b)

with open("json-c.json", "w", encoding="utf-8") as f:
    json.dump(json_c, f, indent=2, ensure_ascii=False)

print("JSON C gerado com sucesso")
