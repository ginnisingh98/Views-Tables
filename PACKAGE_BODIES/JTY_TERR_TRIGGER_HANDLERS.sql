--------------------------------------------------------
--  DDL for Package Body JTY_TERR_TRIGGER_HANDLERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTY_TERR_TRIGGER_HANDLERS" as
/* $Header: jtfyrhdb.pls 120.1.12010000.2 2009/12/17 07:22:38 rajukum ship $ */
--    ---------------------------------------------------
--  Start of Comments
--  ---------------------------------------------------
--  PACKAGE NAME:   JTY_TERR_TRIGGER_HANDLERS
--  ---------------------------------------------------
--  PURPOSE
--    This package defines Territory Trigger handlers.
--    Trigger handler API Spec for TABLES:
--        JTF_TERR, JTF_TERR_VALUES, JTF_TERR_RSC, JTF_TERR_RSC_ACCESS, JTF_TERR_QTYPE_USGS, JTF_TERR_QUAL
--
--  Procedures:
--    (see below for specification)
--
--  HISTORY
--    08/25/05    achanda     Created
--  End of Comments

--**************************************************************
--  Territory_Trigger_Handler
--**************************************************************
PROCEDURE Territory_Trigger_Handler (
    p_terr_id              IN       NUMBER,
    o_parent_territory_id  IN       NUMBER,
    o_start_date_active    IN       DATE,
    o_end_date_active      IN       DATE,
    o_rank                 IN       NUMBER,
    o_num_winners          IN       NUMBER,
    o_named_acct_flag      IN       VARCHAR2,
    n_parent_territory_id  IN       NUMBER,
    n_start_date_active    IN       DATE,
    n_end_date_active      IN       DATE,
    n_rank                 IN       NUMBER,
    n_num_winners          IN       NUMBER,
    n_named_acct_flag      IN       VARCHAR2,
    Trigger_Mode           IN       VARCHAR2)
IS
  l_no_of_records NUMBER;

BEGIN

  IF (Trigger_Mode = 'ON-INSERT') THEN

    IF ((n_start_date_active < sysdate) AND (n_end_date_active > sysdate)) THEN
      INSERT INTO jty_changed_terrs (
         CHANGED_TERRITORY_ID
        ,OBJECT_VERSION_NUMBER
        ,TERR_ID
        ,CHANGE_TYPE
        ,RANK_CALC_FLAG
        ,PROCESS_ATTR_VALUES_FLAG
        ,MATCHING_SQL_FLAG
        ,HIER_PROCESSING_FLAG)
      VALUES (
         jty_changed_terrs_s.nextval
        ,0
        ,p_terr_id
        ,'CREATE'
        ,'Y'
        ,'I'
        ,decode(n_named_acct_flag, 'Y', 'N', 'Y')
        ,'I');
    END IF;

  ELSIF (Trigger_Mode = 'ON-UPDATE') THEN
    IF (o_rank is null and n_rank is not null) OR
       (o_rank is not null and n_rank is null) OR
       (o_rank <> n_rank) THEN
      SELECT count(*)
      INTO   l_no_of_records
      FROM   jty_changed_terrs
      WHERE  terr_id = p_terr_id
      AND    change_type = 'CREATE'
      AND    star_request_id IS NULL;

      IF (l_no_of_records = 0) THEN
        MERGE INTO jty_changed_terrs A
        USING ( SELECT terr_id, source_id from jtf_terr_usgs_all where terr_id = p_terr_id ) S
        ON    ( A.terr_id = S.terr_id AND A.star_request_id IS NULL )
        WHEN MATCHED THEN
          UPDATE SET
             A.rank_calc_flag = 'Y'
        WHEN NOT MATCHED THEN
          INSERT (
             A.CHANGED_TERRITORY_ID
            ,A.OBJECT_VERSION_NUMBER
            ,A.TERR_ID
            ,A.SOURCE_ID
            ,A.CHANGE_TYPE
            ,A.RANK_CALC_FLAG
            ,A.PROCESS_ATTR_VALUES_FLAG
            ,A.MATCHING_SQL_FLAG
            ,A.HIER_PROCESSING_FLAG)
          VALUES (
             jty_changed_terrs_s.nextval
            ,0
            ,S.terr_id
            ,S.source_id
            ,'UPDATE'
            ,'Y'
            ,'N'
            ,'N'
            ,'N');
      END IF; /* end IF (l_no_of_records = 0) */
    END IF; /* end IF (n_rank <> o_rank) */

    IF (o_num_winners is null and n_num_winners is not null) OR
       (o_num_winners is not null and n_num_winners is null) OR
       (o_num_winners <> n_num_winners) THEN
      SELECT count(*)
      INTO   l_no_of_records
      FROM   jty_changed_terrs
      WHERE  terr_id = p_terr_id
      AND    change_type = 'CREATE'
      AND    star_request_id IS NULL;

      IF (l_no_of_records = 0) THEN
        MERGE INTO jty_changed_terrs A
        USING ( SELECT terr_id, source_id from jtf_terr_usgs_all where terr_id = p_terr_id ) S
        ON    ( A.terr_id = S.terr_id AND A.star_request_id IS NULL )
        WHEN MATCHED THEN
          UPDATE SET
             A.HIER_PROCESSING_FLAG = 'I'
        WHEN NOT MATCHED THEN
          INSERT (
             A.CHANGED_TERRITORY_ID
            ,A.OBJECT_VERSION_NUMBER
            ,A.TERR_ID
            ,A.SOURCE_ID
            ,A.CHANGE_TYPE
            ,A.RANK_CALC_FLAG
            ,A.PROCESS_ATTR_VALUES_FLAG
            ,A.MATCHING_SQL_FLAG
            ,A.HIER_PROCESSING_FLAG)
          VALUES (
             jty_changed_terrs_s.nextval
            ,0
            ,S.terr_id
            ,S.source_id
            ,'UPDATE'
            ,'N'
            ,'N'
            ,'N'
            ,'I');
      END IF; /* end IF (l_no_of_records = 0) */
    END IF; /* end IF (n_num_winners <> o_num_winners) */

    IF (n_parent_territory_id <> o_parent_territory_id) THEN

      MERGE INTO jty_changed_terrs A
      USING ( SELECT terr_id, source_id from jtf_terr_usgs_all where terr_id = p_terr_id ) S
      ON    ( A.terr_id = S.terr_id AND A.star_request_id IS NULL )
      WHEN MATCHED THEN
        UPDATE SET
           A.rank_calc_flag = 'Y'
          ,A.process_attr_values_flag = 'I'
          ,A.matching_sql_flag = 'Y'
          ,A.hier_processing_flag = 'I'
      WHEN NOT MATCHED THEN
        INSERT (
           A.CHANGED_TERRITORY_ID
          ,A.OBJECT_VERSION_NUMBER
          ,A.TERR_ID
          ,A.SOURCE_ID
          ,A.CHANGE_TYPE
          ,A.RANK_CALC_FLAG
          ,A.PROCESS_ATTR_VALUES_FLAG
          ,A.MATCHING_SQL_FLAG
          ,A.HIER_PROCESSING_FLAG)
        VALUES (
           jty_changed_terrs_s.nextval
          ,0
          ,S.terr_id
          ,S.source_id
          ,'UPDATE'
          ,'Y'
          ,'I'
          ,'Y'
          ,'I');
    END IF; /* end IF (n_parent_territory_id <> o_parent_territory_id) */

    IF ((o_end_date_active < sysdate and o_start_date_active < sysdate) OR
         (o_end_date_active > sysdate and o_start_date_active > sysdate)) THEN
      IF (n_start_date_active < sysdate and n_end_date_active > sysdate) THEN
        /* future or inactive territory has become active as a result of the change */
        MERGE INTO jty_changed_terrs A
        USING ( SELECT terr_id, source_id from jtf_terr_usgs_all where terr_id = p_terr_id ) S
        ON    ( A.terr_id = S.terr_id AND A.star_request_id IS NULL )
        WHEN MATCHED THEN
          UPDATE SET
             A.rank_calc_flag = 'Y'
            ,A.process_attr_values_flag = 'I'
            ,A.matching_sql_flag = 'Y'
            ,A.hier_processing_flag = 'I'
        WHEN NOT MATCHED THEN
          INSERT (
             A.CHANGED_TERRITORY_ID
            ,A.OBJECT_VERSION_NUMBER
            ,A.TERR_ID
            ,A.SOURCE_ID
            ,A.CHANGE_TYPE
            ,A.RANK_CALC_FLAG
            ,A.PROCESS_ATTR_VALUES_FLAG
            ,A.MATCHING_SQL_FLAG
            ,A.HIER_PROCESSING_FLAG)
          VALUES (
             jty_changed_terrs_s.nextval
            ,0
            ,S.terr_id
            ,S.source_id
            ,'UPDATE'
            ,'Y'
            ,'I'
            ,'Y'
            ,'I');
      END IF;
    ELSIF (o_start_date_active < sysdate and o_end_date_active > sysdate) THEN
      IF ((n_end_date_active < sysdate and n_start_date_active < sysdate) OR
          (n_end_date_active > sysdate and n_start_date_active > sysdate)) THEN
        /* active territory has become future or inactive as a resukt of the change */
        MERGE INTO jty_changed_terrs A
        USING ( SELECT terr_id, source_id from jtf_terr_usgs_all where terr_id = p_terr_id ) S
        ON    ( A.terr_id = S.terr_id AND A.star_request_id IS NULL )
        WHEN MATCHED THEN
          UPDATE SET
             A.rank_calc_flag = 'N'
            ,A.process_attr_values_flag = 'D'
            ,A.matching_sql_flag = 'Y'
            ,A.hier_processing_flag = 'D'
        WHEN NOT MATCHED THEN
          INSERT (
             A.CHANGED_TERRITORY_ID
            ,A.OBJECT_VERSION_NUMBER
            ,A.TERR_ID
            ,A.SOURCE_ID
            ,A.CHANGE_TYPE
            ,A.RANK_CALC_FLAG
            ,A.PROCESS_ATTR_VALUES_FLAG
            ,A.MATCHING_SQL_FLAG
            ,A.HIER_PROCESSING_FLAG)
          VALUES (
             jty_changed_terrs_s.nextval
            ,0
            ,S.terr_id
            ,S.source_id
            ,'UPDATE'
            ,'N'
            ,'D'
            ,'Y'
            ,'D');
      ELSIF ((n_end_date_active > sysdate and n_end_date_active <> o_end_date_active)) THEN
        /* active territory has become future or inactive as a resukt of the change */
        MERGE INTO jty_changed_terrs A
        USING ( SELECT terr_id, source_id from jtf_terr_usgs_all where terr_id = p_terr_id ) S
        ON    ( A.terr_id = S.terr_id AND A.star_request_id IS NULL )
        WHEN MATCHED THEN
          UPDATE SET
             A.rank_calc_flag = 'N'
            ,A.process_attr_values_flag = 'D'
            ,A.matching_sql_flag = 'Y'
            ,A.hier_processing_flag = 'D'
        WHEN NOT MATCHED THEN
          INSERT (
             A.CHANGED_TERRITORY_ID
            ,A.OBJECT_VERSION_NUMBER
            ,A.TERR_ID
            ,A.SOURCE_ID
            ,A.CHANGE_TYPE
            ,A.RANK_CALC_FLAG
            ,A.PROCESS_ATTR_VALUES_FLAG
            ,A.MATCHING_SQL_FLAG
            ,A.HIER_PROCESSING_FLAG)
          VALUES (
             jty_changed_terrs_s.nextval
            ,0
            ,S.terr_id
            ,S.source_id
            ,'UPDATE'
            ,'Y'
            ,'I'
            ,'Y'
            ,'I');
      END IF;
    END IF;
  ELSIF (Trigger_Mode = 'ON-DELETE') THEN

    MERGE INTO jty_changed_terrs A
    USING ( SELECT p_terr_id terr_id from dual ) S
    ON    ( A.terr_id = S.terr_id AND A.star_request_id IS NULL )
    WHEN MATCHED THEN
      UPDATE SET
         A.rank_calc_flag = 'N'
        ,A.process_attr_values_flag = 'D'
        ,A.matching_sql_flag = decode(o_named_acct_flag, 'Y', 'N', 'Y')
        ,A.hier_processing_flag = 'D'
        ,A.change_type = 'DELETE'
    WHEN NOT MATCHED THEN
      INSERT (
         A.CHANGED_TERRITORY_ID
        ,A.OBJECT_VERSION_NUMBER
        ,A.TERR_ID
        ,A.CHANGE_TYPE
        ,A.RANK_CALC_FLAG
        ,A.PROCESS_ATTR_VALUES_FLAG
        ,A.MATCHING_SQL_FLAG
        ,A.HIER_PROCESSING_FLAG)
      VALUES (
         jty_changed_terrs_s.nextval
        ,0
        ,S.terr_id
        ,'DELETE'
        ,'N'
        ,'D'
        ,decode(o_named_acct_flag, 'Y', 'N', 'Y')
        ,'D');
  END IF; /* end IF (Trigger_Mode = 'ON-UPDATE') */

EXCEPTION
  When OTHERS then
    FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERRITORIES_BIUD-Handler', 'Problems: ' || sqlerrm);
    RAISE;
END Territory_Trigger_Handler;

--**************************************************************
--  Terr_Values_Trigger_Handler
--**************************************************************
PROCEDURE Terr_Values_Trigger_Handler(
  p_terr_qual_id IN NUMBER)
IS
  l_terr_id                   NUMBER;
  l_source_id                 NUMBER;
  l_change_type               VARCHAR2(80);
  l_process_attr_values_flag  VARCHAR2(1);
BEGIN

  BEGIN
    SELECT terr_id
    INTO   l_terr_id
    FROM   jtf_terr_qual
    WHERE  terr_qual_id = p_terr_qual_id;
  EXCEPTION
    WHEN NO_DATA_FOUND then
      -- this should never happen since terr_qual_id req'd in jtf_terr_values
      -- and terr_id terr_qual_id required in jtf_terr_qual
      FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_VALUES_BIUD-Handler', 'terr_id does not exist for terr_value_id');
      RAISE;
    WHEN OTHERS then
      FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_VALUES_BIUD-Handler', 'Error while fetching terr_id from terr_value_id: ' || sqlerrm);
      RAISE;
  END;

  BEGIN
    SELECT source_id
    INTO   l_source_id
    FROM   jtf_terr_usgs_all
    WHERE  terr_id = l_terr_id;
  EXCEPTION
    WHEN OTHERS then
      NULL;
  END;

  BEGIN
    SELECT change_type,
           process_attr_values_flag
    INTO   l_change_type,
           l_process_attr_values_flag
    FROM   jty_changed_terrs
    WHERE  terr_id = l_terr_id
    AND    star_request_id IS NULL;

    IF ((l_change_type = 'UPDATE') AND (l_process_attr_values_flag <> 'I')) THEN
      UPDATE jty_changed_terrs
      SET    process_attr_values_flag = 'I'
      WHERE  terr_id = l_terr_id
      AND    star_request_id IS NULL;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      INSERT INTO jty_changed_terrs (
         CHANGED_TERRITORY_ID
        ,OBJECT_VERSION_NUMBER
        ,TERR_ID
        ,SOURCE_ID
        ,CHANGE_TYPE
        ,RANK_CALC_FLAG
        ,PROCESS_ATTR_VALUES_FLAG
        ,MATCHING_SQL_FLAG
        ,HIER_PROCESSING_FLAG)
      VALUES (
         jty_changed_terrs_s.nextval
        ,0
        ,l_terr_id
        ,l_source_id
        ,'UPDATE'
        ,'N'
        ,'I'
        ,'N'
        ,'N');

    WHEN OTHERS THEN
      FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_VALUES_BIUD-Handler', 'Error updating the record: ' || sqlerrm);
      RAISE;
  END;

EXCEPTION
  When OTHERS then
    FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_VALUES_BIUD-Handler', 'Problems: ' || sqlerrm);
    RAISE;

END Terr_Values_Trigger_Handler;

--**************************************************************
--  Terr_Rsc_Trigger_Handler
--**************************************************************
PROCEDURE Terr_Rsc_Trigger_Handler(
  p_TERR_ID IN NUMBER)
IS
  l_no_of_records  NUMBER;
  l_source_id      NUMBER;

BEGIN

  BEGIN
    SELECT source_id
    INTO   l_source_id
    FROM   jtf_terr_usgs_all
    WHERE  terr_id = p_terr_id;
  EXCEPTION
    WHEN OTHERS then
      NULL;
  END;

  SELECT count(*)
  INTO   l_no_of_records
  FROM   jty_changed_terrs
  WHERE  terr_id = p_terr_id
  AND    tap_request_id IS NULL;

  IF (l_no_of_records = 0) THEN
    INSERT INTO jty_changed_terrs (
       CHANGED_TERRITORY_ID
      ,OBJECT_VERSION_NUMBER
      ,TERR_ID
      ,SOURCE_ID
      ,CHANGE_TYPE
      ,RANK_CALC_FLAG
      ,PROCESS_ATTR_VALUES_FLAG
      ,MATCHING_SQL_FLAG
      ,HIER_PROCESSING_FLAG)
    VALUES (
       jty_changed_terrs_s.nextval
      ,0
      ,p_terr_id
      ,l_source_id
      ,'UPDATE'
      ,'N'
      ,'N'
      ,'N'
      ,'N');
  END IF;

EXCEPTION
  When OTHERS then
    FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_RSC_BIUD-Handler', 'Problems: ' || sqlerrm);
    RAISE;

END Terr_Rsc_Trigger_Handler;

--**************************************************************
--  Terr_QType_Trigger_Handler
--**************************************************************

PROCEDURE Terr_QType_Trigger_Handler(
  p_terr_id IN NUMBER)
IS
  l_change_type               VARCHAR2(80);
  l_process_attr_values_flag  VARCHAR2(1);
  l_source_id                 NUMBER;
BEGIN

  BEGIN
    SELECT source_id
    INTO   l_source_id
    FROM   jtf_terr_usgs_all
    WHERE  terr_id = p_terr_id;
  EXCEPTION
    WHEN OTHERS then
      NULL;
  END;

  BEGIN
    SELECT change_type,
           process_attr_values_flag
    INTO   l_change_type,
           l_process_attr_values_flag
    FROM   jty_changed_terrs
    WHERE  terr_id = p_terr_id
    AND    star_request_id IS NULL;

    IF ((l_change_type = 'UPDATE') AND (l_process_attr_values_flag <> 'I')) THEN
      UPDATE jty_changed_terrs
      SET    process_attr_values_flag = 'I',
             matching_sql_flag = 'Y'
      WHERE  terr_id = p_terr_id
      AND    star_request_id IS NULL;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      INSERT INTO jty_changed_terrs (
         CHANGED_TERRITORY_ID
        ,OBJECT_VERSION_NUMBER
        ,TERR_ID
        ,SOURCE_ID
        ,CHANGE_TYPE
        ,RANK_CALC_FLAG
        ,PROCESS_ATTR_VALUES_FLAG
        ,MATCHING_SQL_FLAG
        ,HIER_PROCESSING_FLAG)
      VALUES (
         jty_changed_terrs_s.nextval
        ,0
        ,p_terr_id
        ,l_source_id
        ,'UPDATE'
        ,'N'
        ,'I'
        ,'Y'
        ,'N');

    WHEN OTHERS THEN
      FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_QTYPE_BIUD-Handler', 'Error updating the record: ' || sqlerrm);
      RAISE;
  END;

EXCEPTION
  When OTHERS then
    FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_QTYPE_BIUD-Handler', 'Problems: ' || sqlerrm);
    RAISE;

END Terr_QType_Trigger_Handler;

--**************************************************************
--  Terr_RscAccess_Trigger_Handler
--**************************************************************
PROCEDURE Terr_RscAccess_Trigger_Handler(
  p_terr_rsc_id IN NUMBER)
IS
  l_terr_id        NUMBER;
  l_no_of_records  NUMBER;
  l_source_id      NUMBER;

BEGIN

  BEGIN
    Select terr_id
    into   l_terr_id
    from   jtf_terr_rsc_all
    where  terr_rsc_id = p_terr_rsc_id;
  EXCEPTION
    When OTHERS then
      FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_RSC_BIUD-Handler', 'Error getting terr_id: ' || sqlerrm);
      RAISE;
  End;

  BEGIN
    SELECT source_id
    INTO   l_source_id
    FROM   jtf_terr_usgs_all
    WHERE  terr_id = l_terr_id;
  EXCEPTION
    WHEN OTHERS then
      NULL;
  END;

  SELECT count(*)
  INTO   l_no_of_records
  FROM   jty_changed_terrs
  WHERE  terr_id = l_terr_id
  AND    tap_request_id IS NULL;

  IF (l_no_of_records = 0) THEN
    INSERT INTO jty_changed_terrs (
       CHANGED_TERRITORY_ID
      ,OBJECT_VERSION_NUMBER
      ,TERR_ID
      ,SOURCE_ID
      ,CHANGE_TYPE
      ,RANK_CALC_FLAG
      ,PROCESS_ATTR_VALUES_FLAG
      ,MATCHING_SQL_FLAG
      ,HIER_PROCESSING_FLAG)
    VALUES (
       jty_changed_terrs_s.nextval
      ,0
      ,l_terr_id
      ,l_source_id
      ,'UPDATE'
      ,'N'
      ,'N'
      ,'N'
      ,'N');
  END IF;

EXCEPTION
  When OTHERS then
    FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_RSC_ACCESS_BIUD-Handler', 'Problems: ' || sqlerrm);
    RAISE;
END Terr_RscAccess_Trigger_Handler;


PROCEDURE Terr_Qual_Trigger_Handler(
  p_terr_id IN NUMBER)
IS
  l_change_type        VARCHAR2(80);
  l_matching_sql_flag  VARCHAR2(1);
  l_source_id          NUMBER;
BEGIN

  BEGIN
    SELECT source_id
    INTO   l_source_id
    FROM   jtf_terr_usgs_all
    WHERE  terr_id = p_terr_id;
  EXCEPTION
    WHEN OTHERS then
      NULL;
  END;

  BEGIN
    SELECT change_type,
           matching_sql_flag
    INTO   l_change_type,
           l_matching_sql_flag
    FROM   jty_changed_terrs
    WHERE  terr_id = p_terr_id
    AND    star_request_id IS NULL;

    IF ((l_change_type = 'UPDATE') AND (l_matching_sql_flag <> 'Y')) THEN
      UPDATE jty_changed_terrs
      SET    matching_sql_flag = 'Y'
      WHERE  terr_id = p_terr_id
      AND    star_request_id IS NULL;
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      INSERT INTO jty_changed_terrs (
         CHANGED_TERRITORY_ID
        ,OBJECT_VERSION_NUMBER
        ,TERR_ID
        ,SOURCE_ID
        ,CHANGE_TYPE
        ,RANK_CALC_FLAG
        ,PROCESS_ATTR_VALUES_FLAG
        ,MATCHING_SQL_FLAG
        ,HIER_PROCESSING_FLAG)
      VALUES (
         jty_changed_terrs_s.nextval
        ,0
        ,p_terr_id
        ,l_source_id
        ,'UPDATE'
        ,'N'
        ,'N'
        ,'Y'
        ,'N');

    WHEN OTHERS THEN
      FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_QUAL_BIUD-Handler', 'Error updating the record: ' || sqlerrm);
      RAISE;
  END;

EXCEPTION
  When OTHERS then
    FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_QUAL_BIUD-Handler', 'Problems: ' || sqlerrm);
    RAISE;

END Terr_Qual_Trigger_Handler;


PROCEDURE Terr_Usgs_Trigger_Handler(
  p_terr_id       IN NUMBER,
  p_source_id     IN NUMBER,
  triggering_mode IN VARCHAR2)
IS
BEGIN
  IF (triggering_mode = 'ON-INSERT') THEN
    MERGE INTO jty_changed_terrs A
    USING ( SELECT p_terr_id terr_id, p_source_id source_id from dual ) S
    ON    ( A.terr_id = S.terr_id AND A.star_request_id IS NULL )
    WHEN MATCHED THEN
      UPDATE SET
         A.source_id = S.source_id
    WHEN NOT MATCHED THEN
      INSERT (
         A.CHANGED_TERRITORY_ID
        ,A.OBJECT_VERSION_NUMBER
        ,A.TERR_ID
        ,A.SOURCE_ID
        ,A.CHANGE_TYPE
        ,A.RANK_CALC_FLAG
        ,A.PROCESS_ATTR_VALUES_FLAG
        ,A.MATCHING_SQL_FLAG
        ,A.HIER_PROCESSING_FLAG)
      VALUES (
         jty_changed_terrs_s.nextval
        ,0
        ,S.terr_id
        ,S.source_id
        ,'CREATE'
        ,'Y'
        ,'I'
        ,'Y'
        ,'I');
  ELSIF (triggering_mode = 'ON-DELETE') THEN
    MERGE INTO jty_changed_terrs A
    USING ( SELECT p_terr_id terr_id, p_source_id source_id from dual ) S
    ON    ( A.terr_id = S.terr_id AND A.star_request_id IS NULL )
    WHEN MATCHED THEN
      UPDATE SET
         A.source_id = S.source_id
    WHEN NOT MATCHED THEN
      INSERT (
         A.CHANGED_TERRITORY_ID
        ,A.OBJECT_VERSION_NUMBER
        ,A.TERR_ID
        ,A.SOURCE_ID
        ,A.CHANGE_TYPE
        ,A.RANK_CALC_FLAG
        ,A.PROCESS_ATTR_VALUES_FLAG
        ,A.MATCHING_SQL_FLAG
        ,A.HIER_PROCESSING_FLAG)
      VALUES (
         jty_changed_terrs_s.nextval
        ,0
        ,S.terr_id
        ,S.source_id
        ,'DELETE'
        ,'N'
        ,'D'
        ,'Y'
        ,'D');
  END IF;

EXCEPTION
  When OTHERS then
    FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_USGS_BIUD-Handler', 'Problems: ' || sqlerrm);
    RAISE;

END Terr_Usgs_Trigger_Handler;

END JTY_TERR_TRIGGER_HANDLERS;

/
