--------------------------------------------------------
--  DDL for Package Body IEU_DEFAULT_MEDIA_ENUMS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_DEFAULT_MEDIA_ENUMS_PVT" AS
/* $Header: IEUENMVB.pls 120.1 2006/02/21 22:54:14 nsardana noship $ */

-- Sub-Program Units

PROCEDURE UPDATE_SEL_RT_NODE
  (P_RESOURCE_ID           IN IEU_UWQ_SEL_RT_NODES.RESOURCE_ID%TYPE
  ,P_SEL_ENUM_ID           IN IEU_UWQ_SEL_RT_NODES.SEL_ENUM_ID%TYPE
  ,P_NODE_ID               IN IEU_UWQ_SEL_RT_NODES.NODE_ID%TYPE
  ,P_NODE_TYPE             IN IEU_UWQ_SEL_RT_NODES.NODE_TYPE%TYPE
  ,P_NODE_LABEL            IN IEU_UWQ_SEL_RT_NODES.NODE_LABEL%TYPE
  ,P_DATA_SOURCE           IN IEU_UWQ_SEL_RT_NODES.DATA_SOURCE%TYPE
  ,P_VIEW_NAME             IN IEU_UWQ_SEL_RT_NODES.VIEW_NAME%TYPE
  ,P_MEDIA_TYPE_ID         IN IEU_UWQ_SEL_RT_NODES.MEDIA_TYPE_ID%TYPE
  ,P_SEL_ENUM_PID          IN IEU_UWQ_SEL_RT_NODES.SEL_ENUM_PID%TYPE
  ,P_NODE_PID              IN IEU_UWQ_SEL_RT_NODES.NODE_PID%TYPE
  ,P_NODE_WEIGHT           IN IEU_UWQ_SEL_RT_NODES.NODE_WEIGHT%TYPE
  ,P_WHERE_CLAUSE          IN IEU_UWQ_SEL_RT_NODES.WHERE_CLAUSE%TYPE
  ,P_HIDE_IF_EMPTY         IN IEU_UWQ_SEL_RT_NODES.HIDE_IF_EMPTY%TYPE
  ,P_REFRESH_VIEW_NAME     IN IEU_UWQ_SEL_RT_NODES.REFRESH_VIEW_NAME%TYPE
  ,P_REFRESH_VIEW_SUM_COL  IN IEU_UWQ_SEL_RT_NODES.REFRESH_VIEW_SUM_COL%TYPE
  ,P_NODE_DEPTH	  	   IN IEU_UWQ_SEL_RT_NODES.NODE_DEPTH%TYPE		-- Added for bug 4389449
  )
  AS
  l_node_id	NUMBER;
BEGIN


  IF ( (P_RESOURCE_ID IS NULL) OR
       (P_SEL_ENUM_ID IS NULL) OR
       (P_NODE_ID IS NULL) OR
       (P_NODE_TYPE IS NULL) OR
       (P_NODE_LABEL IS NULL) )
  THEN
    raise_application_error
      (-20000
      ,'A required parameter is null' ||
       '. (P_RESOURCE_ID = ' || P_RESOURCE_ID ||
       ') (P_SEL_ENUM_ID = ' || P_SEL_ENUM_ID ||
       ') (P_NODE_ID = ' || P_NODE_ID ||
       ') (P_NODE_TYPE = ' || P_NODE_TYPE ||
       ') (P_NODE_LABEL = ' || P_NODE_LABEL ||
       ')'
      ,TRUE );
  END IF;


  SAVEPOINT start_update;

--    All subnodes start with a series under the PID.
      l_node_id := P_NODE_ID + P_NODE_PID;

  BEGIN
    UPDATE IEU_UWQ_SEL_RT_NODES
      SET
        LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
        LAST_UPDATE_DATE = SYSDATE,
        LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID,
        NODE_LABEL = P_NODE_LABEL,
        DATA_SOURCE = P_DATA_SOURCE,
        VIEW_NAME = P_VIEW_NAME,
        REFRESH_VIEW_NAME = P_REFRESH_VIEW_NAME,
        REFRESH_VIEW_SUM_COL = P_REFRESH_VIEW_SUM_COL,
        NODE_PID = P_NODE_PID,
        NODE_WEIGHT = P_NODE_WEIGHT,
        WHERE_CLAUSE = P_WHERE_CLAUSE,
        HIDE_IF_EMPTY = P_HIDE_IF_EMPTY,
        COUNT = NULL,
        NOT_VALID = 'N',
	NODE_DEPTH = P_NODE_DEPTH			-- Added for bug 4389449
      WHERE
        (RESOURCE_ID = P_RESOURCE_ID) AND
        (SEL_ENUM_ID = P_SEL_ENUM_ID) AND
        (NODE_ID = l_node_id) AND
        (NODE_TYPE = P_NODE_TYPE) AND
        (NODE_PID = P_NODE_PID);


    IF (SQL%NOTFOUND OR (SQL%ROWCOUNT <= 0)) THEN

      INSERT INTO IEU_UWQ_SEL_RT_NODES
        ( SEL_RT_NODE_ID,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,
          RESOURCE_ID,
          SEL_ENUM_ID,
          NODE_ID,
          NODE_TYPE,
          NODE_LABEL,
          COUNT,
          DATA_SOURCE,
          VIEW_NAME,
          REFRESH_VIEW_NAME,
          REFRESH_VIEW_SUM_COL,
          MEDIA_TYPE_ID,
          SEL_ENUM_PID,
          NODE_PID,
          NODE_WEIGHT,
          WHERE_CLAUSE,
          HIDE_IF_EMPTY,
          NOT_VALID,
	  NODE_DEPTH)					-- Added for bug 4389449
        VALUES (
          IEU_UWQ_SEL_RT_NODES_S1.NEXTVAL,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.USER_ID,
          SYSDATE,
          FND_GLOBAL.LOGIN_ID,
          P_RESOURCE_ID,
          P_SEL_ENUM_ID,
          l_node_id,
          P_NODE_TYPE,
          P_NODE_LABEL,
          NULL,
          P_DATA_SOURCE,
          P_VIEW_NAME,
          P_REFRESH_VIEW_NAME,
          P_REFRESH_VIEW_SUM_COL,
          P_MEDIA_TYPE_ID,
          P_SEL_ENUM_PID,
          P_NODE_PID,
          P_NODE_WEIGHT,
          P_WHERE_CLAUSE,
          P_HIDE_IF_EMPTY,
          'N',
	  P_NODE_DEPTH);				-- Added for bug 4389449

    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO start_update;
      RAISE;

  END;

END UPDATE_SEL_RT_NODE;

PROCEDURE CREATE_MYWORK_NODE
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  )
AS

BEGIN
	-- Niraj, 21-Feb-2006, Obsoleted procedure
	NULL;
END CREATE_MYWORK_NODE;

PROCEDURE CREATE_BLENDED_NODE
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  )
  AS

  l_node_label       VARCHAR(512);
  l_blended_node_id  NUMBER := 10000;

BEGIN

  SELECT
    tl.media_type_name
  INTO
    l_node_label
  FROM
    IEU_UWQ_MEDIA_TYPES_TL tl
  WHERE
    (tl.media_type_id = IEU_CONSTS_PUB.G_MTID_BLENDED) AND
    (tl.language = userenv('LANG'));

  UPDATE_SEL_RT_NODE
    ( P_RESOURCE_ID,
      0,
      l_blended_node_id,          -- NODE_ID
      0,                          -- NODE_TYPE
      l_node_label,               -- NODE_LABEL
      'IEU_UWQ_BLENDED_DS',       -- DATA_SOURCE
      'IEU_UWQ_BLENDED_V',        -- VIEW_NAME
      NULL,                       -- MEDIA_TYPE_ID
      0,                          -- SEL_ENUM_PID
      0,                          -- NODE_PID
      nvl(IEU_UWQ_UTIL_PUB.to_number_noerr(fnd_profile.value('IEU_QOR_BLENDED')), 6000),          -- NODE_WEIGHT
      '',                         -- WHERE_CLAUSE
      NULL,                        -- HIDE_IF_EMPTY
      'IEU_UWQ_BLENDED_V',        -- REFRESH_VIEW_NAME
      'QUEUE_COUNT',               -- REFRESH_VIEW_SUM_COL
      1				  -- NODE_DEPTH		-- Added for bug 4389449
    );

END CREATE_BLENDED_NODE;

-- Niraj:  Bug 4389449: Added Node Depth column in this proc for
-- handling UWQ Media nodes like Web Callback, Inbound Telephony
PROCEDURE ENUMERATE_MEDIA_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_NODE_ID          IN NUMBER
  ,P_SEL_ENUM_ID      IN NUMBER
  ,P_SEL_ENUM_PID     IN NUMBER
  ,P_DATA_SRC         IN VARCHAR2
  ,P_VIEW_NAME        IN VARCHAR2
  ,P_MEDIA_TYPE_ID    IN NUMBER
  ,P_LOOKUP_CODE      IN VARCHAR2
  ,P_P_LOOKUP_CODE    IN VARCHAR2
  ,P_HIDE_IF_EMPTY    IN VARCHAR2
  ,P_NODE_DEPTH	      IN NUMBER		-- Added for bug 4389449
  )
  AS

  l_wb_style       VARCHAR2(2);
  l_node_label     VARCHAR2(2000);
  l_media_type_id  NUMBER := 0;
  l_p_node_label   VARCHAR2(100);
  l_media_node_id  NUMBER;

BEGIN

  l_media_node_id  := IEU_CONSTS_PUB.G_SNID_MEDIA;
  -- First we have to check if the agent is blended or not... if they
  -- are, then any attempt to enumerate media nodes must simply return
  -- the blended node.

  l_wb_style := ieu_pvt.determine_wb_style( p_resource_id );

  if ( (l_wb_style = 'F') or  (l_wb_style = 'SF') )     -- Full/Simple Forced Blending
  then
    create_blended_node( p_resource_id, p_language, p_source_lang );
    return;
  elsif ( (l_wb_style = 'O') or (l_wb_style = 'SO') )   -- Full/Simple Optional Blending
  then
    create_blended_node( p_resource_id, p_language, p_source_lang );
  end if;


  -- If we make it this far, then we are insertting media nodes in a
  -- non-blended fashion (where agents can pick the queues).

  SELECT
    tl.media_type_name,
    b.media_type_id
  INTO
    l_node_label,
    l_media_type_id
  FROM
    IEU_UWQ_MEDIA_TYPES_TL tl,
    IEU_UWQ_MEDIA_TYPES_B b
  WHERE
    (tl.media_type_id = b.media_type_id) AND
    (tl.language = userenv('LANG')) AND
    (b.media_type_id = p_media_type_id);

  Select meaning into l_p_node_label
    from fnd_lookup_values_vl
    where lookup_type = 'IEU_NODE_LABELS'
    and view_application_id = 696
    and lookup_code = P_P_LOOKUP_CODE;

  UPDATE_SEL_RT_NODE
    ( P_RESOURCE_ID,
      P_SEL_ENUM_ID,
      P_NODE_ID,             -- NODE_ID
      0,                     -- NODE_TYPE
      l_node_label,          -- NODE_LABEL
      P_DATA_SRC,            -- DATA_SOURCE
      P_VIEW_NAME,           -- VIEW_NAME
      l_media_type_id,       -- MEDIA_TYPE_ID
      P_SEL_ENUM_PID,        -- SEL_ENUM_PID
      l_media_node_id,       -- NODE_PID
      P_NODE_ID,             -- NODE_WEIGHT
      '',                    -- WHERE_CLAUSE
      P_HIDE_IF_EMPTY,       -- HIDE_IF_EMPTY
      P_VIEW_NAME,           -- REFRESH_VIEW_NAME
      'QUEUE_COUNT',          -- REFRESH_VIEW_SUM_COL
      P_NODE_DEPTH	     -- NODE_DEPTH		-- Added for bug 4389449
    );

END ENUMERATE_MEDIA_NODES;


PROCEDURE ENUMERATE_OUTBOUND_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  )
AS
BEGIN
 	-- Niraj, 21-Feb-2006, Obsoleted procedure
	NULL;
END ENUMERATE_OUTBOUND_NODES;


PROCEDURE ENUMERATE_INBOUND_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  )
  AS

BEGIN

  IF ( FALSE = IEU_PVT.IS_MEDIA_TYPE_ELIGIBLE
                 (P_RESOURCE_ID
                 ,IEU_CONSTS_PUB.G_MTID_INBOUND_TELEPHONY)
     )
  THEN
    RETURN;
  END IF;

  ENUMERATE_MEDIA_NODES
    (P_RESOURCE_ID
    ,P_LANGUAGE
    ,P_SOURCE_LANG
    ,20
    ,P_SEL_ENUM_ID
    ,P_SEL_ENUM_ID
    ,'IEU_UWQ_INBOUND_TEL_DS'
    ,'IEU_UWQ_INBOUND_TEL_V'
    ,IEU_CONSTS_PUB.G_MTID_INBOUND_TELEPHONY
    ,'IEU_INBOUND_LBL'
    ,'IEU_MEDIA_LBL'
    ,NULL
    ,2);				-- Added for bug 4389449

END ENUMERATE_INBOUND_NODES;


PROCEDURE ENUMERATE_EMAIL_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  )
AS
BEGIN
	-- Niraj, 21-Feb-2006, Obsoleted procedure
	NULL;
END ENUMERATE_EMAIL_NODES;


PROCEDURE ENUMERATE_WEB_CALLBACK_NODES
  (P_RESOURCE_ID      IN NUMBER
  ,P_LANGUAGE         IN VARCHAR2
  ,P_SOURCE_LANG      IN VARCHAR2
  ,P_SEL_ENUM_ID      IN NUMBER
  )
  AS

BEGIN

  IF ( FALSE = IEU_PVT.IS_MEDIA_TYPE_ELIGIBLE
                 (P_RESOURCE_ID
                 ,IEU_CONSTS_PUB.G_MTID_WEB_CALLBACK)
     )
  THEN
    RETURN;
  END IF;

  ENUMERATE_MEDIA_NODES
    (P_RESOURCE_ID
    ,P_LANGUAGE
    ,P_SOURCE_LANG
    ,40
    ,P_SEL_ENUM_ID
    ,P_SEL_ENUM_ID
    ,'IEU_UWQ_WEB_CALLBACK_DS'
    ,'IEU_UWQ_WEB_CALLBACK_V'
    ,IEU_CONSTS_PUB.G_MTID_WEB_CALLBACK
    ,'IEU_WEB_CALLBACK_LBL'
    ,'IEU_MEDIA_LBL'
    ,NULL
    ,2);				-- Added for bug 4389449

END ENUMERATE_WEB_CALLBACK_NODES;


-- PL/SQL Block
END IEU_DEFAULT_MEDIA_ENUMS_PVT;

/
