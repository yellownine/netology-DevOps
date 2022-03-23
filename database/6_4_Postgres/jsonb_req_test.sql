create table treeusers (id bigserial primary key, jsonnData jsonb not null);

INSERT INTO treeusers (jsonnData) VALUES
  ('{
    "id": 4,
    "projects": [
      {"resource": 7, "owner": "me"},
      {"resource": 8, "owner": "you"}
      ]
    }'),
  ('{
    "id": 2,
    "projects": [
      {"resource": 3, "owner": "he"},
      {"resource": 4, "owner": "she"}
      ]
    }'),
  ('{
    "id": 3,
    "projects": [
      {"resource": 5, "owner": "he"},
      {"resource": 6, "owner": "she"}
      ]
    }');


    select (jsonnData->>'id')
    from treeusers,
         jsonb_array_elements(jsonnData->'projects') pr
    where (pr ->> 'owner')::text = 'she';
