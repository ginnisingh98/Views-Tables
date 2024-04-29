--------------------------------------------------------
--  DDL for Package Body POS_HZ_RELATIONSHIPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POS_HZ_RELATIONSHIPS_PKG" AS
/*$Header: POSHZPRB.pls 120.1 2005/10/27 12:37:16 bitang noship $ */

procedure pos_create_relationship(
                            p_subject_id IN NUMBER,
                            p_object_id  IN NUMBER,
                            p_relationship_type IN VARCHAR2,
                            p_relationship_code IN VARCHAR2,

                           x_party_relationship_id OUT NOCOPY NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_exception_msg OUT NOCOPY VARCHAR2)
IS
l_object_type varchar2(200);
l_subject_type varchar2(200);
BEGIN
    x_exception_msg := 'pos_create_relationship():select object_type';
    select party_type
    into l_object_type
    from hz_parties
    where party_id = p_object_id;

    x_exception_msg := 'select subject_type';
    select party_type
    into l_subject_type
    from hz_parties
    where party_id = p_subject_id;

    x_exception_msg := 'Calling the pos_hz_create_relationship';
    pos_hz_create_relationship( p_subject_id => p_subject_id
                              , p_object_id  => p_object_id
                              , p_relationship_type => p_relationship_type
                              , p_relationship_code => p_relationship_code
                              , p_party_object_type => l_object_type
                              , p_party_subject_type => l_subject_type
                              , p_subject_table_name => 'HZ_PARTIES'
                              , p_object_table_name  => 'HZ_PARTIES'
                              , p_relationship_status => 'A'
                              , p_relationship_start_date => NULL
                              , p_relationship_end_date => NULL
                              , x_party_relationship_id => x_party_relationship_id
                              , x_return_status => x_return_status
                              , x_exception_msg => x_exception_msg
                              );
   IF x_return_status <> 'S' THEN
    raise_application_error(-20001, 'pos_create_relationship():' || x_exception_msg || p_relationship_type || p_relationship_code || l_object_type || l_subject_type,true);
   END IF;

EXCEPTION
  WHEN OTHERS THEN
    /* Check for the exceptions */
    raise_application_error(-20001, 'pos_create_relationship():' || x_exception_msg,true);
END pos_create_relationship;

/* You dont have to call this method directly. Helper procedures will be
 * created.
 */
procedure pos_hz_create_relationship(
                           p_subject_id IN NUMBER,
                           p_object_id  IN NUMBER,
                           p_relationship_type IN VARCHAR2,
                           p_relationship_code IN VARCHAR2,
                           p_party_object_type IN VARCHAR2,
                           p_party_subject_type IN VARCHAR2,
                           p_subject_table_name IN VARCHAR2,
                           p_object_table_name  IN VARCHAR2,
                           p_relationship_status IN VARCHAR2 := NULL, -- can be null
                           p_relationship_start_date IN DATE := NULL, -- can be null
                           p_relationship_end_date IN DATE := NULL,   -- can be null

                           x_party_relationship_id OUT NOCOPY NUMBER,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_exception_msg OUT NOCOPY VARCHAR2
                           )
IS
  l_rel_rec       hz_relationship_v2pub.relationship_rec_type;

  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(240);
  l_party_relationship_id    NUMBER;
  l_party_id      NUMBER;
  l_party_number  VARCHAR2(30);
  l_return_status VARCHAR2(1);

BEGIN

  l_rel_rec.subject_id := p_subject_id;
  l_rel_rec.object_id  := p_object_id;

  l_rel_rec.subject_table_name := p_subject_table_name;
  l_rel_rec.object_table_name := p_object_table_name;

  l_rel_rec.relationship_code := p_relationship_code;
  l_rel_rec.relationship_type := p_relationship_type;

  l_rel_rec.subject_type := p_party_subject_type;
  l_rel_rec.object_type  := p_party_object_type;

  l_rel_rec.created_by_module := 'POS_SUPPLIER_MGMT';
  l_rel_rec.application_id := 177;

  if p_object_id IS NULL then
    x_exception_msg := 'POS_HZ_RELATIONSHIPS_PKG.pos_create_relationship_all_args(): Failed to object_id cannot be null';
    x_return_status := 'E'; /* JP changed it to 'E' from 'S' */
    return;
  end if;

  IF p_subject_id IS NULL THEN
    x_exception_msg := 'POS_HZ_RELATIONSHIPS_PKG.pos_create_relationship_all_args(): Failed to subject_id cannot be null';
    x_return_status := 'E';
    return;
  END IF;

  IF p_relationship_start_date IS NOT NULL THEN
    l_rel_rec.start_date:= p_relationship_start_date;
  ELSE
    l_rel_rec.start_date:= SYSDATE;
  END IF;

  IF p_relationship_status IS NULL THEN
    l_rel_rec.status := 'A';
  ELSE
    l_rel_rec.status := p_relationship_status;
  END IF;

  IF p_relationship_end_date IS NOT NULL THEN
    l_rel_rec.end_date := p_relationship_end_date;
  END IF;

  hz_relationship_v2pub.create_relationship(
                          --p_api_version   => 1.0
                         p_init_msg_list => fnd_api.g_true
                         ,p_relationship_rec => l_rel_rec
                         ,x_relationship_id => l_party_relationship_id
                         ,x_party_id      => l_party_id
                         ,x_party_number  => l_party_number
                         --,p_commit   => fnd_api.g_false
                         ,x_return_status => l_return_status
                         ,x_msg_count     => l_msg_count
                         ,x_msg_data      => l_msg_data
                         --,p_validation_level => FND_API.G_VALID_LEVEL_FULL
                         );

  x_party_relationship_id := l_party_relationship_id;
  x_return_status := l_return_status;
  x_exception_msg := l_msg_data;

  IF x_return_status <> 'S' THEN
  -- There has been an error
  BEGIN
    --raise;
    raise_application_error(-20001, 'POS_HZ_RELATIONSHIPS_PKG:pos_create_relationship(): Create relationship failed :' || x_exception_msg || p_relationship_type || p_relationship_code || p_party_subject_type || p_party_object_type, true);
  END;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    raise_application_error(-20001, 'POS_HZ_RELATIONSHIPS_PKG:pos_create_relationship(): Create relationship failed :' || x_exception_msg || p_relationship_type || p_relationship_code || p_party_subject_type || p_party_object_type, true);
END pos_hz_create_relationship;

/*
procedure pos_outdate_relationship_args ( p_subject_id IN NUMBER,
                                   p_object_id IN NUMBER,
                                   p_relationship_type IN VARCHAR2,
                                   p_relationship_code IN VARCHAR2,
                                   p_party_object_type IN VARCHAR2,
                                   p_party_subject_type IN VARCHAR2,
                                   p_subject_table_name IN VARCHAR2,
                                   p_object_table_name  IN VARCHAR2,
                                   x_status OUT NOCOPY number,
                                   x_exceptions_msg OUT NOCOPY VARCHAR2
                                   )
IS
l_count NUMBER;
BEGIN
    x_status = 'S';
    select count(*)
    into l_count
    from hz_relationships
    where object_table_name = p_object_table_name
    and   subject_table_name = p_subject_table_name
    and   object_type = p_party_object_type
    and   subject_type = p_party_subject_type
    and   relationship_code = p_relationship_code
    and   relationship_type = p_relationship_type
    and   object_id = p_object_id
    and   subject_id = p_subject_id;

    IF l_count = 0 THEN
        x_status = 'E'; -- Failure, because the relationship does not exist
        x_exception_msg = 'pos_hz_relationships_pkg.pos_outdate_relationships_args():The requested relationship does not exist';
        return;
    END IF;

    x_exceptions_msg := 'Ending the relationship ';

    update hz_relationships
    set end_date := SYSDATE, status := 'A'
    where object_table_name = p_object_table_name
    and   subject_table_name = p_subject_table_name
    and   object_type = p_party_object_type
    and   subject_type = p_party_subject_type
    and   relationship_code = p_relationship_code
    and   relationship_type = p_relationship_type
    and   object_id = p_object_id
    and   subject_id = p_subject_id;

EXCEPTION
    WHEN OTHERS THEN
    POS_UTIL_PKG.raise_error('POS_HZ_RELATIONSHIPS_PKG:pos_outdate_relationship_args():' || x_exception_msg);
END;

END pos_outdate_relationship_args;
*/

/* Donot call this directly instead use pos_outdate_relationship() when
   possible
*/
procedure pos_hz_update_relationship(p_subject_id IN NUMBER,
                           p_object_id  IN NUMBER,
                           p_relationship_type IN VARCHAR2,
                           p_relationship_code IN VARCHAR2,
                           p_party_object_type IN VARCHAR2,
                           p_party_subject_type IN VARCHAR2,
                           p_subject_table_name IN VARCHAR2,
                           p_object_table_name  IN VARCHAR2,
                          -- p_relationship_status IN VARCHAR2, -- should not be updated
                           p_relationship_start_date IN DATE, -- can be null
                           p_relationship_end_date IN DATE,   -- can be null

                           p_relationship_id IN NUMBER,
                           p_object_version_number in number,

                           p_rel_last_update_date IN OUT NOCOPY DATE,
                           p_party_last_update_date IN OUT NOCOPY  DATE,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_exception_msg OUT NOCOPY VARCHAR2)
IS
  l_rel_rec       hz_relationship_v2pub.relationship_rec_type;
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(240);
  l_party_id      NUMBER;
  l_party_number  VARCHAR2(30);
  l_return_status VARCHAR2(1);
  l_rel_last_update_date date;
  l_party_last_update_date date;
  l_proc_name varchar2(50);
  l_obj_ver number;
  l_party_obj_ver number;
BEGIN
  l_proc_name := 'pos_hz_update_relationship';
  l_obj_ver := p_object_version_number;
  l_rel_rec.subject_id := p_subject_id;
  l_rel_rec.object_id  := p_object_id;

  l_rel_rec.subject_table_name := p_subject_table_name;
  l_rel_rec.object_table_name := p_object_table_name;

  l_rel_rec.relationship_code := p_relationship_code;
  l_rel_rec.relationship_type := p_relationship_type;
  l_rel_rec.subject_type := p_party_subject_type;
  l_rel_rec.object_type  := p_party_object_type;

  l_rel_rec.created_by_module := 'POS_SUPPLIER_MGMT';
  l_rel_rec.application_id := 177;

  if p_object_id IS NULL then
    x_return_status := 'E';
    x_exception_msg := l_proc_name || 'Object id cannot be null';
    return;
  end if;

  if p_subject_id IS NULL then
    x_return_status := 'E';
    x_exception_msg := l_proc_name || 'subject id cannot be null';
    return;
  end if;

  IF p_relationship_start_date IS NOT NULL THEN
    l_rel_rec.start_date:= p_relationship_start_date;
  END IF;

  IF p_relationship_end_date IS NOT NULL THEN
    l_rel_rec.end_date := p_relationship_end_date;
  END IF;

  IF p_relationship_id IS NOT NULL THEN
    l_rel_rec.relationship_id := p_relationship_id;
  ELSE
    x_return_status := 'E';
    x_exception_msg := l_proc_name || ' relationship_id cannot be null';
    return;
  END IF;

  /* Do not update the l_rel_rec.status variable. Because this value
     is slightly confusing is typically handled by TCA.
  */

  hz_relationship_v2pub.update_relationship(
                          --p_api_version   => 1.0
                         p_init_msg_list => FND_API.G_TRUE
                         --,p_commit => FND_API.G_FALSE
                         ,p_relationship_rec => l_rel_rec
                         ,p_object_version_number => l_obj_ver
                         ,p_party_object_version_number => l_party_obj_ver
                         --,p_rel_last_update_date => l_rel_last_update_date
                         --,p_party_last_update_date => l_party_last_update_date
                         ,x_return_status => l_return_status
                         ,x_msg_count     => l_msg_count
                         ,x_msg_data      => l_msg_data

                         --,x_relationship_id => l_party_relationship_id
                         --,x_party_id      => l_party_id
                         --,x_party_number  => l_party_number
                         );

  x_return_status := l_return_status;
  x_exception_msg := l_msg_data;

  IF x_return_status <> 'S' THEN
    -- There has been an error
    BEGIN
        raise_application_error(-20001,'POS_HZ_RELATIONSHIPS_PKG:pos_outdate_relationship(): Update relationship failed :' || x_exception_msg, true);
    END;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
      raise_application_error(-20001,'POS_HZ_RELATIONSHIPS_PKG:pos_outdate_relationship(): Update relationship failed :' || x_exception_msg,true);
    --x_return_status := 'U';
    --x_exception_msg := 'DEBUG: in pos_hz_relationships_pkg.update_or_insert';
END pos_hz_update_relationship;

procedure pos_outdate_relationship(
                            p_subject_id IN NUMBER,
                            p_object_id  IN NUMBER,
                            p_relationship_type IN VARCHAR2,
                            p_relationship_code IN VARCHAR2,
                           x_return_status OUT NOCOPY VARCHAR2,
                           x_exception_msg OUT NOCOPY VARCHAR2)
IS
l_object_type varchar2(200);
l_subject_type varchar2(200);
l_party_date date;
l_rel_date date;
l_relationship_id number ;
l_obj_ver number;
BEGIN
    x_exception_msg := 'pos_outdate_relationship():select object_type';
    select party_type
    into l_object_type
    from hz_parties
    where party_id = p_object_id;

    x_exception_msg := 'select subject_type';
    select party_type
    into l_subject_type
    from hz_parties
    where party_id = p_subject_id;

    x_exception_msg := 'selecting distinct relationship id';

    select distinct relationship_id, object_version_number
    into l_relationship_id, l_obj_ver
    from hz_relationships
    where start_date <= sysdate
    and end_date >= sysdate
    and status = 'A'
    and object_table_name = 'HZ_PARTIES'
    and subject_table_name = 'HZ_PARTIES'
    and object_type = l_object_type
    and subject_type = l_subject_type
    and relationship_code = p_relationship_code
    and relationship_type = p_relationship_type
    and object_id = p_object_id
    and subject_id = p_subject_id;

    x_exception_msg := 'Calling the pos_hz_update_relationship';
    pos_hz_update_relationship( p_subject_id => p_subject_id
                              , p_object_id  => p_object_id
                              , p_relationship_type => p_relationship_type
                              , p_relationship_code => p_relationship_code
                              , p_party_object_type => l_object_type
                              , p_party_subject_type => l_subject_type
                              , p_subject_table_name => 'HZ_PARTIES'
                              , p_object_table_name  => 'HZ_PARTIES'
                              , p_relationship_end_date => SYSDATE
                              , p_relationship_start_date => NULL
                              , p_relationship_id => l_relationship_id
                              , p_object_version_number => l_obj_ver
                              , p_rel_last_update_date => l_rel_date
                              , p_party_last_update_date => l_party_date
                              , x_return_status => x_return_status
                              , x_exception_msg => x_exception_msg
                              );
   IF x_return_status <> 'S' THEN
    raise_application_error(-20001, 'pos_outdate_relationship():' || x_exception_msg, true);
   END IF;
EXCEPTION
  WHEN OTHERS THEN
    /* Check for the exceptions */
    raise_application_error(-20001, 'pos_outdate_relationship():' || x_exception_msg,true);
END pos_outdate_relationship;

procedure GET_RELATING_PARTY_ID(p_subject_id IN NUMBER,
                                p_relationship_type IN VARCHAR2,
                                p_relationship_code IN VARCHAR2,
                                x_object_id  OUT NOCOPY NUMBER,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_exception_msg OUT NOCOPY VARCHAR2)
IS
  l_object_id     NUMBER;
BEGIN

  select object_id
    into l_object_id
    from hz_relationships
   where subject_id = p_subject_id
     and relationship_type = p_relationship_type
     and relationship_code = p_relationship_code
     and status = 'A'
     and start_date <= sysdate
     and end_date >= sysdate;

  x_return_status := 'S';
  x_object_id     := l_object_id;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_return_status := 'S';  -- No problem, a person may not have a boss!
  WHEN OTHERS THEN
    x_return_status := 'U';
    x_exception_msg := 'DEBUG: POS_HZ_RELATIONSHIPS_PKG.get_relating_party_id';
    raise_application_error(-20001, x_exception_msg, true);
END GET_RELATING_PARTY_ID;


procedure pos_outdate_relationship(
        p_relationship_id IN NUMBER,
        p_object_version_num IN NUMBER,
        x_return_status OUT NOCOPY VARCHAR2,
        x_exception_msg OUT NOCOPY VARCHAR2)
IS

  l_rel_rec       hz_relationship_v2pub.relationship_rec_type;
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(240);
  l_exception_msg varchar2(500);
  l_party_obj_ver number;

  l_obj_ver       number;
BEGIN

    l_exception_msg := 'POSHZRPB:V2:Start of out date relationship:';
    l_rel_rec.relationship_id := p_relationship_id;
    l_rel_rec.end_date := sysdate;
    l_rel_rec.status := 'I';
    l_obj_ver := p_object_version_num;

    l_exception_msg := 'POSHZRPB:V2:Calling hz update relationship:';
    hz_relationship_v2pub.update_relationship(
                         p_init_msg_list => FND_API.G_TRUE
                         ,p_relationship_rec => l_rel_rec
                         ,p_object_version_number => l_obj_ver
                         ,p_party_object_version_number => l_party_obj_ver
                         ,x_return_status => x_return_status
                         ,x_msg_count     => l_msg_count
                         ,x_msg_data      => l_msg_data
                         );
    x_exception_msg := l_msg_data;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
    x_exception_msg := 'Caught exception in pos_outdate_relationship:V2:';
    raise_application_error(-20001, x_exception_msg||' at :'
        || l_exception_msg, true);
END pos_outdate_relationship;

END POS_HZ_RELATIONSHIPS_PKG;

/
