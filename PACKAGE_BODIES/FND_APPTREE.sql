--------------------------------------------------------
--  DDL for Package Body FND_APPTREE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_APPTREE" AS
/* $Header: AFTREEB.pls 120.2 2005/10/24 06:09:54 mzasowsk ship $ */

PROCEDURE get_folder_properties (l_folder_id        number,
                                 l_obj_name         OUT NOCOPY /* file.sql.39 change */ varchar2,
                                 l_node_label       OUT NOCOPY /* file.sql.39 change */ varchar2,
                                 l_folder_type      OUT NOCOPY /* file.sql.39 change */ varchar2,
                                 l_value            OUT NOCOPY /* file.sql.39 change */ varchar2,
                                 l_sequence         OUT NOCOPY /* file.sql.39 change */ number,
                                 l_parent_folder_id OUT NOCOPY /* file.sql.39 change */ number,
                                 l_user_id          OUT NOCOPY /* file.sql.39 change */ number,
                                 l_public_flag      OUT NOCOPY /* file.sql.39 change */ varchar2) IS
  cursor props is
    select obj_name, node_label, folder_type,
           value, sequence, parent_folder_id, created_by, public_flag
    from   fnd_tree_folders
    where  folder_id = l_folder_id;
BEGIN
  open props;
  fetch props into l_obj_name, l_node_label, l_folder_type,
           l_value, l_sequence, l_parent_folder_id, l_user_id, l_public_flag;
  if props%NOTFOUND then
    l_obj_name := 'NOT_FOUND';
  end if;
  close props;
END get_folder_properties;

FUNCTION insert_folder(l_obj_name         VARCHAR2,
                       l_node_label       VARCHAR2,
                       l_folder_type      VARCHAR2,
                       l_value            VARCHAR2,
                       l_parent_folder_id NUMBER,
                       l_public_flag      VARCHAR2,
                       l_language         VARCHAR2,
                       l_user_id          NUMBER,
                       after_folder_id    NUMBER default null) RETURN NUMBER IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_next_seq     number;
  l_folder_id    number;
  l_after_seq    number;
  cursor max_seq_null_parent is
      select max(sequence)
      from   fnd_tree_folders
      where  created_by = l_user_id
      and    parent_folder_id is null
      and    obj_name = l_obj_name;
  cursor max_seq_in_parent is
      select max(sequence)
      from   fnd_tree_folders
      where  parent_folder_id = l_parent_folder_id;
  cursor seq_of_folder is
      select sequence
      from   fnd_tree_folders
      where  folder_id = after_folder_id;
  cursor next_seq_null_parent is
      select min(sequence)
      from   fnd_tree_folders
      where  created_by = l_user_id
      and    parent_folder_id is null
      and    obj_name = l_obj_name
      and    sequence > l_after_seq;
  cursor next_seq_in_parent is
      select min(sequence)
      from   fnd_tree_folders
      where  parent_folder_id = l_parent_folder_id
      and    sequence > l_after_seq;
  cursor next_folder_id is
    select fnd_tree_folders_s.nextval
    from dual;
BEGIN
  --
  -- Determine the next sequence number.
  --
  if after_folder_id is null then
    --
    -- Find last sequenced entry in that parent
    --
    if l_parent_folder_id is null then
      open max_seq_null_parent;
      fetch max_seq_null_parent into l_next_seq;
      if max_seq_null_parent%NOTFOUND then
        l_next_seq := 0;
      end if;
      close max_seq_null_parent;
    else
      open max_seq_in_parent;
      fetch max_seq_in_parent into l_next_seq;
      if max_seq_in_parent%NOTFOUND then
        l_next_seq := 0;
      end if;
      close max_seq_in_parent;
    end if;
    l_next_seq := nvl(l_next_seq, 0.0) + 1.0;
  else
    --
    -- Find next sequenced entry beyond after_folder_id
    -- within that parent
    --
    open seq_of_folder;
    fetch seq_of_folder into l_after_seq;
    if seq_of_folder%NOTFOUND then
      close seq_of_folder;
      raise NO_DATA_FOUND;
    end if;
    close seq_of_folder;

    if l_parent_folder_id is null then
      open next_seq_null_parent;
      fetch max_seq_null_parent into l_next_seq;
      if next_seq_null_parent%NOTFOUND then
        l_next_seq := null;
      end if;
      close next_seq_null_parent;
    else
      open next_seq_in_parent;
      fetch next_seq_in_parent into l_next_seq;
      if next_seq_in_parent%NOTFOUND then
        l_next_seq := null;
      end if;
      close next_seq_in_parent;
    end if;
    if l_next_seq is null then
      l_next_seq := l_after_seq + 1.0;
    else
      l_next_seq := (l_next_seq + l_after_seq) / 2.0;
    end if;
  end if;
  --
  -- Get the folder_id from the sequence
  --
  open next_folder_id;
  fetch next_folder_id into l_folder_id;
  close next_folder_id;
  --
  insert into fnd_tree_folders(
    folder_id,
    obj_name,
    node_label,
    folder_type,
    value,
    sequence,
    parent_folder_id,
    public_flag,
    language,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by)
  values (
    l_folder_id,
    l_obj_name,
    l_node_label,
    l_folder_type,
    l_value,
    l_next_seq,
    l_parent_folder_id,
    l_public_flag,
    l_language,
    sysdate,
    l_user_id,
    sysdate,
    l_user_id);
  COMMIT;
  return l_folder_id;
EXCEPTION
  when others then
    return -1;
END insert_folder;

PROCEDURE update_folder (l_folder_id        number,
                         l_user_id          number,
                         l_obj_name         varchar2 default 'APPTREE_NULL',
                         l_node_label       VARCHAR2 default 'APPTREE_NULL',
                         l_folder_type      VARCHAR2 default 'APPTREE_NULL',
                         l_value            VARCHAR2 default 'APPTREE_NULL',
                         l_sequence         NUMBER   default -99,
                         l_parent_folder_id NUMBER   default -99,
                         l_public_flag      VARCHAR2 default 'APPTREE_NULL',
                         l_language         VARCHAR2 default 'APPTREE_NULL') IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  update fnd_tree_folders
  set
    obj_name         = decode(l_obj_name,         'APPTREE_NULL', obj_name,         l_obj_name),
    node_label       = decode(l_node_label,       'APPTREE_NULL', node_label,       l_node_label),
    folder_type      = decode(l_folder_type,      'APPTREE_NULL', folder_type,      l_folder_type),
    value            = decode(l_value,            'APPTREE_NULL', value,            l_value),
    sequence         = decode(l_sequence,         -99,            sequence,         l_sequence),
    parent_folder_id = decode(l_parent_folder_id, -99,            parent_folder_id, l_parent_folder_id),
    public_flag      = decode(l_public_flag,      'APPTREE_NULL', public_flag,      l_public_flag),
    language         = decode(l_language,         'APPTREE_NULL', language,         l_language),
    last_update_date = sysdate,
    last_updated_by = l_user_id
  where
    folder_id = l_folder_id;
  COMMIT;
END update_folder;
FUNCTION unique_name(requested_folder_name varchar2,
                     l_parent_folder_id    number,
                     l_obj_name            varchar2,
                     l_user_id             number) return varchar2 is
  trouble     varchar2(1) := null;
  cursor matches is
    select '1'
    from fnd_tree_folders
    where  ((l_parent_folder_id is null and parent_folder_id is null)
           or (l_parent_folder_id is not null and parent_folder_id = l_parent_folder_id))
    and    obj_name = l_obj_name
    and    created_by = l_user_id
    and    folder_type IN ('Q', 'F')
    and    node_label = requested_folder_name;
BEGIN
  open matches;
  fetch matches into trouble;
  if matches%found then
    close matches;
    return 'N';
  else
    close matches;
    return 'Y';
  end if;
END unique_name;

PROCEDURE delete_folder(l_folder_id number) is
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  delete
  from fnd_tree_folders f
  where f.folder_id in
    (select h.folder_id
     from fnd_tree_folders h
     start with h.folder_id = l_folder_id
     connect by prior h.folder_id = h.parent_folder_id);
  --
  commit;
END delete_folder;

FUNCTION move_folder( l_folder_id        number
                     ,l_parent_folder_id number
                     ,after_folder_id    number
                     ,l_user_id          number
                     ,l_obj_name          varchar) return number is
PRAGMA AUTONOMOUS_TRANSACTION;
  l_next_seq     number;
  l_after_seq    number;
  cursor max_seq_null_parent is
      select max(sequence)
      from   fnd_tree_folders
      where  created_by = l_user_id
      and    parent_folder_id is null
      and    obj_name = l_obj_name;
  cursor max_seq_in_parent is
      select max(sequence)
      from   fnd_tree_folders
      where  parent_folder_id = l_parent_folder_id;
  cursor seq_of_folder is
      select sequence
      from   fnd_tree_folders
      where  folder_id = after_folder_id;
  cursor next_seq_null_parent is
      select min(sequence)
      from   fnd_tree_folders
      where  created_by = l_user_id
      and    parent_folder_id is null
      and    obj_name = l_obj_name
      and    sequence > l_after_seq;
  cursor next_seq_in_parent is
      select min(sequence)
      from   fnd_tree_folders
      where  parent_folder_id = l_parent_folder_id
      and    sequence > l_after_seq;
BEGIN
  --
  -- Determine the next sequence number.
  --
  if after_folder_id is null then
    --
    -- Find last sequenced entry in that parent
    --
    if l_parent_folder_id is null then
      open max_seq_null_parent;
      fetch max_seq_null_parent into l_next_seq;
      if max_seq_null_parent%NOTFOUND then
        l_next_seq := 0;
      end if;
      close max_seq_null_parent;
    else
      open max_seq_in_parent;
      fetch max_seq_in_parent into l_next_seq;
      if max_seq_in_parent%NOTFOUND then
        l_next_seq := 0;
      end if;
      close max_seq_in_parent;
    end if;
    l_next_seq := nvl(l_next_seq, 0.0) + 1.0;
  else
    --
    -- Find next sequenced entry beyond after_folder_id
    -- within that parent
    --
    open seq_of_folder;
    fetch seq_of_folder into l_after_seq;
    if seq_of_folder%NOTFOUND then
      close seq_of_folder;
      raise NO_DATA_FOUND;
    end if;
    close seq_of_folder;

    if l_parent_folder_id is null then
      open next_seq_null_parent;
      fetch max_seq_null_parent into l_next_seq;
      if next_seq_null_parent%NOTFOUND then
        l_next_seq := null;
      end if;
      close next_seq_null_parent;
    else
      open next_seq_in_parent;
      fetch next_seq_in_parent into l_next_seq;
      if next_seq_in_parent%NOTFOUND then
        l_next_seq := null;
      end if;
      close next_seq_in_parent;
    end if;
    if l_next_seq is null then
      l_next_seq := l_after_seq + 1.0;
    else
      l_next_seq := (l_next_seq + l_after_seq) / 2.0;
    end if;
  end if;

  UPDATE fnd_tree_folders
    SET parent_folder_id = l_parent_folder_id
       ,sequence = l_next_seq
       ,last_update_date = sysdate
       ,last_updated_by  = l_user_id
  WHERE folder_id = l_folder_id;
  COMMIT;
  return l_folder_id;
EXCEPTION
  when others then
    return -1;
end move_folder;


END fnd_apptree;

/
