--------------------------------------------------------
--  DDL for Package Body AHL_FMP_COMMON_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_FMP_COMMON_PVT" AS
/* $Header: AHLVFCMB.pls 120.7.12010000.4 2010/01/24 10:11:45 sracha ship $ */

G_PKG_NAME              VARCHAR2(30):='AHL_FMP_COMMON_PVT';
G_APPLN_USAGE           VARCHAR2(30):=LTRIM(RTRIM(FND_PROFILE.VALUE('AHL_APPLN_USAGE')));
G_DEBUG                 VARCHAR2(1):=AHL_DEBUG_PUB.is_log_enabled;

-- local procedures

-- Check to see whether a VARCHAR2 contains only numeric values
FUNCTION sn_num(
  p_serial_number                IN    VARCHAR2
) RETURN BOOLEAN;


-- Procedure to validate lookups
PROCEDURE validate_lookup
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_lookup_type          IN            FND_LOOKUPS.lookup_type%TYPE,
  p_lookup_meaning       IN            FND_LOOKUPS.meaning%TYPE,
  p_x_lookup_code        IN OUT NOCOPY FND_LOOKUPS.lookup_code%TYPE
)
IS

l_lookup_code      FND_LOOKUPS.lookup_code%TYPE;

CURSOR get_rec_from_value ( c_lookup_type FND_LOOKUPS.lookup_type%TYPE,
                            c_lookup_meaning FND_LOOKUPS.meaning%TYPE )
IS
SELECT  lookup_code
FROM    FND_LOOKUP_VALUES_VL
WHERE   lookup_type = c_lookup_type
AND     meaning = c_lookup_meaning
AND      SYSDATE BETWEEN NVL( start_date_active, SYSDATE ) AND
                                NVL( end_date_active, SYSDATE );

CURSOR get_rec_from_id ( c_lookup_type FND_LOOKUPS.lookup_type%TYPE,
                         c_lookup_code FND_LOOKUPS.lookup_code%TYPE )
IS
SELECT lookup_code
FROM   FND_LOOKUP_VALUES_VL
WHERE           lookup_type = c_lookup_type
AND             lookup_code = c_lookup_code
AND             SYSDATE BETWEEN NVL( start_date_active, SYSDATE ) AND
                                NVL( end_date_active, SYSDATE );

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_lookup_type IS NULL OR
       p_lookup_type = FND_API.G_MISS_CHAR ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_lookup_meaning IS NULL OR
         p_lookup_meaning = FND_API.G_MISS_CHAR ) AND
       ( p_x_lookup_code IS NULL OR
         p_x_lookup_code = FND_API.G_MISS_CHAR ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_lookup_meaning IS NULL OR
         p_lookup_meaning = FND_API.G_MISS_CHAR ) AND
       ( p_x_lookup_code IS NOT NULL AND
         p_x_lookup_code <> FND_API.G_MISS_CHAR ) ) THEN

    OPEN get_rec_from_id( p_lookup_type, p_x_lookup_code );

    FETCH get_rec_from_id INTO
      l_lookup_code;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_COM_INVALID_LOOKUP';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_lookup_meaning IS NOT NULL AND
       p_lookup_meaning <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_lookup_type, p_lookup_meaning );

    LOOP
      FETCH get_rec_from_value INTO
        l_lookup_code;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_lookup_code = p_x_lookup_code ) THEN
        CLOSE get_rec_from_value;
        RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_COM_INVALID_LOOKUP';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_lookup_code := l_lookup_code;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_COM_TOO_MANY_LOOKUPS';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_lookup;

-- Procedure to validate Item
PROCEDURE validate_item
(
  x_return_status        OUT NOCOPY    VARCHAR2,
  x_msg_data             OUT NOCOPY    VARCHAR2,
  p_item_number          IN             MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE,
  p_x_inventory_item_id  IN OUT NOCOPY  MTL_SYSTEM_ITEMS.inventory_item_id%TYPE
)
IS

CURSOR get_rec_from_value ( c_item_number MTL_SYSTEM_ITEMS_KFV.concatenated_segments%TYPE )
IS
SELECT DISTINCT MI.inventory_item_id,
                MI.inventory_item_flag,
                MI.eng_item_flag,
                MI.build_in_wip_flag,
                MI.wip_supply_type,
                MI.eam_item_type,
                MI.comms_nl_trackable_flag,
                MI.serv_req_enabled_code
FROM            MTL_PARAMETERS MP, MTL_SYSTEM_ITEMS_KFV MI
WHERE DECODE(G_APPLN_USAGE,'PM','Y',MP.eam_enabled_flag )='Y'
AND             MP.organization_id = MI.organization_id
AND             MI.concatenated_segments = c_item_number
AND             MI.enabled_flag = 'Y'
AND             SYSDATE BETWEEN NVL( MI.start_date_active, SYSDATE )
                        AND     NVL( MI.end_date_active, SYSDATE );

l_item_rec2 get_rec_from_value%rowtype;

CURSOR get_rec_from_id ( c_inventory_item_id MTL_SYSTEM_ITEMS.inventory_item_id%TYPE )
IS
SELECT DISTINCT MI.inventory_item_id,
                MI.inventory_item_flag,
                MI.eng_item_flag,
                MI.build_in_wip_flag,
                MI.wip_supply_type,
                MI.eam_item_type,
                MI.comms_nl_trackable_flag,
                MI.serv_req_enabled_code
FROM            MTL_PARAMETERS MP, MTL_SYSTEM_ITEMS_KFV MI
WHERE DECODE(G_APPLN_USAGE,'PM','Y',MP.eam_enabled_flag )='Y'
AND             MP.organization_id = MI.organization_id
AND             MI.inventory_item_id = c_inventory_item_id
AND             MI.enabled_flag = 'Y'
AND             SYSDATE BETWEEN NVL( MI.start_date_active, SYSDATE )
                        AND     NVL( MI.end_date_active, SYSDATE );
l_item_rec1 get_rec_from_id%rowtype;
l_rec_found     VARCHAR2(1):=FND_API.G_FALSE;
L_REC_COUNT     NUMBER:=0;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_item_number IS NULL OR
         p_item_number = FND_API.G_MISS_CHAR ) AND
       ( p_x_inventory_item_id IS NULL OR
         p_x_inventory_item_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_item_number IS NULL OR
         p_item_number = FND_API.G_MISS_CHAR ) AND
       ( p_x_inventory_item_id IS NOT NULL AND
         p_x_inventory_item_id <> FND_API.G_MISS_NUM ) )
  THEN
    OPEN get_rec_from_id( p_x_inventory_item_id );
    LOOP
    FETCH get_rec_from_id INTO  l_item_rec1;
      EXIT WHEN get_rec_from_id%NOTFOUND;
        L_REC_COUNT:=L_REC_COUNT+1;

        IF G_APPLN_USAGE<>'PM'
        THEN
                IF l_item_rec1.inventory_item_flag='Y'     and
                   l_item_rec1.eng_item_flag='N'           and
                   l_item_rec1.build_in_wip_flag='Y'      and
                   l_item_rec1.wip_supply_type=1         and
                   l_item_rec1.eam_item_type=3           and
                   l_item_rec1.comms_nl_trackable_flag='Y'
                THEN
                        l_rec_found:=FND_API.G_TRUE;
                END IF;
        ELSIF G_APPLN_USAGE='PM'
        THEN
                IF l_item_rec1.comms_nl_trackable_flag='Y' and
                   l_item_rec1.serv_req_enabled_code='E'
                THEN
                        l_rec_found:=FND_API.G_TRUE;
                END IF;
        END IF;
        EXIT WHEN l_rec_found=FND_API.G_TRUE;
    END LOOP;
    CLOSE get_rec_from_id;

    IF L_REC_COUNT=0
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := 'AHL_FMP_INVALID_ITEM';
        RETURN;
    END IF;

    IF l_rec_found=FND_API.G_FALSE
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := 'AHL_FMP_NOT_JOB_ITEM';
    END IF;
    RETURN;

  ELSIF p_item_number IS NOT NULL AND
        p_item_number <> FND_API.G_MISS_CHAR
  THEN
        L_REC_COUNT:=0;
        OPEN get_rec_from_value( p_item_number );
        LOOP
        FETCH get_rec_from_value INTO  L_ITEM_REC2;

        EXIT WHEN get_rec_from_value%NOTFOUND;
        L_REC_COUNT:=L_REC_COUNT+1;
        p_x_inventory_item_id := l_item_rec2.inventory_item_id;

        IF  G_APPLN_USAGE<>'PM'   -- NOT PM MODE
        THEN
                IF l_item_rec2.inventory_item_flag='Y'     and
                   l_item_rec2.eng_item_flag='N'           and
                   l_item_rec2.build_in_wip_flag='Y'       and
                   l_item_rec2.wip_supply_type=1           and
                   l_item_rec2.eam_item_type=3             and
                   l_item_rec2.comms_nl_trackable_flag='Y'
                THEN
                        l_rec_found:=FND_API.G_TRUE;
                END IF;
        ELSIF G_APPLN_USAGE='PM' -- PM MODE
        THEN
                IF l_item_rec2.comms_nl_trackable_flag='Y'   and
                   l_item_rec2.serv_req_enabled_code='E'
                THEN
                        l_rec_found:=FND_API.G_TRUE;
                END IF;
        END IF;

        END LOOP;

        CLOSE get_rec_from_value;

        IF L_REC_COUNT=0
        THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_data := 'AHL_FMP_INVALID_ITEM';
                RETURN;
        END IF;

        IF l_rec_found=FND_API.G_FALSE
        THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_data := 'AHL_FMP_NOT_JOB_ITEM';
        END IF;

        RETURN;
  END IF;
  -- END OF ITEM NUMBER CHECK
END validate_item;





PROCEDURE validate_pc_node
(
 x_return_status      OUT NOCOPY    VARCHAR2,
 x_msg_data           OUT NOCOPY    VARCHAR2,
 p_pc_node_name       IN            VARCHAR2 := NULL,
 p_x_pc_node_id       IN OUT NOCOPY NUMBER
)
IS

l_pc_node_id      NUMBER;

CURSOR get_rec_from_value ( c_pc_node_name VARCHAR2 )
IS
SELECT  pc_node_id
FROM            AHL_PC_NODES_B
WHERE           name = c_pc_node_name;

CURSOR get_rec_from_id ( c_pc_node_id NUMBER )
IS
SELECT  pc_node_id
FROM            AHL_PC_NODES_B
WHERE           pc_node_id = c_pc_node_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_pc_node_name IS NULL OR
         p_pc_node_name = FND_API.G_MISS_CHAR ) AND
       ( p_x_pc_node_id IS NULL OR
         p_x_pc_node_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_pc_node_name IS NULL OR
         p_pc_node_name = FND_API.G_MISS_CHAR ) AND
       ( p_x_pc_node_id IS NOT NULL AND
         p_x_pc_node_id <> FND_API.G_MISS_NUM ) ) THEN

    OPEN get_rec_from_id( p_x_pc_node_id );

    FETCH get_rec_from_id INTO
      l_pc_node_id;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_INVALID_PC_NODE';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_pc_node_name IS NOT NULL AND
       p_pc_node_name <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_pc_node_name );

    LOOP
      FETCH get_rec_from_value INTO
        l_pc_node_id;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_pc_node_id = p_x_pc_node_id ) THEN
        CLOSE get_rec_from_value;
        RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_INVALID_PC_NODE';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_pc_node_id := l_pc_node_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_TOO_MANY_PC_NODES';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_pc_node;

/*pdoki commented for Bug 6032303 - Start
PROCEDURE validate_position
(
 x_return_status           OUT NOCOPY    VARCHAR2,
 x_msg_data                OUT NOCOPY    VARCHAR2,
 p_position_ref_meaning    IN            VARCHAR2 := NULL,
 p_x_relationship_id       IN OUT NOCOPY NUMBER
)
IS

l_relationship_id      NUMBER;

l_valid_rec_found      BOOLEAN := FALSE;
l_posn_meaning         FND_LOOKUPS.meaning%TYPE;
l_junk                 VARCHAR2(1);
*/
/*CURSOR get_rec_from_value ( c_position_ref_meaning VARCHAR2 )
IS
SELECT DISTINCT relationship_id,
                NVL( active_start_date, SYSDATE ),
                NVL( active_end_date, SYSDATE + 1 )
FROM            AHL_MASTER_CONFIG_DETAILS_V
WHERE           position_ref_meaning = c_position_ref_meaning;

CURSOR get_rec_from_id ( c_relationship_id NUMBER )
IS
SELECT DISTINCT relationship_id,
                NVL( active_start_date, SYSDATE ),
                NVL( active_end_date, SYSDATE + 1 )
FROM            AHL_RELATIONSHIPS_VL
WHERE           relationship_id = c_relationship_id;
*/

-- 11.5.10 changes for MC
/*
CURSOR get_rec_from_id ( c_relationship_id NUMBER )
IS
SELECT relationship_id
FROM  ahl_mc_relationships mcr,
ahl_mc_headers_b mch,   ahl_mc_path_position_nodes mcp
where mch.mc_header_id = mcr.mc_header_id and
mch.mc_id = mcp.mc_id and
mch.version_number = nvl(mcp.version_number, mch.version_number) and
mcr.position_key = mcp.position_key and
mcp.sequence = (select max(sequence)
                from ahl_mc_path_position_nodes
                where path_position_id = nvl(c_relationship_id,'-1'))
and mcp.path_position_id = nvl(c_relationship_id,'-1');

CURSOR check_reln_valid_csr (c_relationship_id IN NUMBER)
IS
SELECT 'x'
FROM ahl_mc_relationships
WHERE parent_relationship_id IS NULL
START WITH relationship_id = c_relationship_id
           AND trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1))
CONNECT BY PRIOR parent_relationship_id = relationship_id
           AND trunc(sysdate) < trunc(nvl(active_end_date,sysdate+1));


BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_position_ref_meaning IS NULL OR
         p_position_ref_meaning = FND_API.G_MISS_CHAR ) AND
       ( p_x_relationship_id IS NULL OR
         p_x_relationship_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( --( p_position_ref_meaning IS NULL OR
         --p_position_ref_meaning = FND_API.G_MISS_CHAR ) AND
       ( p_x_relationship_id IS NOT NULL AND
         p_x_relationship_id <> FND_API.G_MISS_NUM ) ) THEN

    FOR relationship_rec IN get_rec_from_id( p_x_relationship_id ) LOOP

       -- Check if position is valid.
       OPEN check_reln_valid_csr(relationship_rec.relationship_id);
       FETCH check_reln_valid_csr INTO l_junk;
       IF (check_reln_valid_csr%NOTFOUND) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_data := 'AHL_FMP_INVALID_MC_POS_STATUS';
          CLOSE check_reln_valid_csr;

       ELSE
          IF (p_position_ref_meaning IS NOT NULL AND
              p_position_ref_meaning <> FND_API.G_MISS_CHAR ) THEN

              l_posn_meaning := AHL_MC_PATH_POSITION_PVT.GET_POSREF_BY_ID(relationship_rec.relationship_id);
              IF (l_posn_meaning <> p_position_ref_meaning) THEN
                 x_return_status := FND_API.G_RET_STS_ERROR;
                 x_msg_data := 'AHL_FMP_INVALID_MC_POS_MEANING';
              ELSE
                 -- exit when at least one valid relationship found.
                 l_valid_rec_found := TRUE;
                 EXIT;
              END IF;
          ELSE
            -- exit when at least one valid relationship found.
            l_valid_rec_found := TRUE;
            EXIT;
          END IF;
       END IF;

    END LOOP;

    IF NOT(l_valid_rec_found) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_data := 'AHL_FMP_INVALID_MC_POSITION';

    END IF;

    RETURN;

  END IF;

  IF ( p_position_ref_meaning IS NOT NULL AND
       p_position_ref_meaning <> FND_API.G_MISS_CHAR ) THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_TOO_MANY_MC_POSITIONS';

    RETURN;
  END IF;
END validate_position;
--pdoki commented for Bug 6032303 - End */

--pdoki added for Bug 6032303 - Start
PROCEDURE validate_position
(
 x_return_status           OUT NOCOPY    VARCHAR2,
 x_msg_data                OUT NOCOPY    VARCHAR2,
 p_position_ref_meaning    IN            VARCHAR2 := NULL,
 p_x_relationship_id       IN OUT NOCOPY NUMBER
)
IS
l_mc_header_id         NUMBER;
l_posn_meaning         FND_LOOKUPS.meaning%TYPE;
l_dummy_char           VARCHAR2(1);

CURSOR get_mc_header_id ( c_relationship_id NUMBER )
IS
SELECT mch.mc_header_id
FROM ahl_mc_headers_b mch, ahl_mc_path_position_nodes mcp
WHERE
mch.mc_id = mcp.mc_id and
mch.version_number = nvl(mcp.version_number, mch.version_number) and
mcp.sequence = (select max(sequence)
                from ahl_mc_path_position_nodes
                where path_position_id = nvl(c_relationship_id,'-1'))
and mcp.path_position_id = nvl(c_relationship_id,'-1');

CURSOR check_mc_status ( c_mc_header_id NUMBER )
IS
SELECT 'X'
FROM ahl_mc_headers_b
WHERE mc_header_id = c_mc_header_id AND
config_status_code = 'COMPLETE';

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

--If position meaning and path_position_id is null then throw 'invalid procedure call' error.

  IF ( ( p_position_ref_meaning IS NULL OR
         p_position_ref_meaning = FND_API.G_MISS_CHAR ) AND
       ( p_x_relationship_id IS NULL OR
         p_x_relationship_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

--If position meaning is not null but path_position_id is null, then throw error asking user to pick position from LOV.
  IF ( ( p_position_ref_meaning IS NOT NULL AND
       p_position_ref_meaning <> FND_API.G_MISS_CHAR ) AND
       ( p_x_relationship_id IS NULL OR
         p_x_relationship_id = FND_API.G_MISS_NUM ) ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_TOO_MANY_MC_POSITIONS';
    RETURN;
  END IF;

--Following validations are done only when the path_postion_id is NOT null as we return to the caller API in the above cases.

--Retrieving the mc_header_id to check if the MC is complete.
    OPEN get_mc_header_id(p_x_relationship_id);
    FETCH get_mc_header_id INTO l_mc_header_id;
    IF (get_mc_header_id%NOTFOUND) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_data := 'AHL_FMP_INVALID_MC_POSITION';
       CLOSE get_mc_header_id;
       RETURN;
    END IF;
    CLOSE get_mc_header_id;

--Throw error if MC is not complete.
    OPEN check_mc_status(l_mc_header_id);
    FETCH check_mc_status INTO l_dummy_char;
    IF (check_mc_status%NOTFOUND) THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_data := 'AHL_FMP_MC_NOT_COMPLETE';
       CLOSE check_mc_status;
       RETURN;
    END IF;
    CLOSE check_mc_status;

--Retrieve path_position_meaning and check with the path_position_id passed to the API.
--Throw invalid MC position error if no position_ref_meaning is returned.
--Throw error 'Invalid Master Configuration Position FIELD entered for Effectivity RECORD.'if they dont match
--Fix for Bug 6032303. Calling below function with the path_position_id
  l_posn_meaning := AHL_MC_PATH_POSITION_PVT.GET_POSREF_BY_ID(p_x_relationship_id);
  IF (l_posn_meaning IS NULL) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_INVALID_MC_POSITION';
  ELSIF (p_position_ref_meaning IS NOT NULL AND l_posn_meaning <> p_position_ref_meaning) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_data := 'AHL_FMP_INVALID_MC_POS_MEANING';
  END IF;

END validate_position;
--pdoki added for Bug 6032303 - End

PROCEDURE validate_position_item
(
 x_return_status           OUT NOCOPY    VARCHAR2,
 x_msg_data                OUT NOCOPY    VARCHAR2,
 p_inventory_item_id       IN            NUMBER,
 p_relationship_id         IN            NUMBER
)
IS

l_dummy        VARCHAR2(1);

CURSOR check_alternate( c_relationship_id NUMBER, c_inventory_item_id NUMBER )
IS
SELECT 'X'
FROM ahl_mc_relationships mcr,
     ahl_mc_headers_b mch,
     ahl_mc_path_position_nodes mcp,
     --ahl_item_associations_v igass ,
   ahl_item_associations_vl igass, --priyan changes due to performance reasons , Refer Bug # 5078530
     mtl_system_items_kfv MTL,
     mtl_item_status STAT,
     fnd_lookup_values_vl IT
WHERE mch.mc_header_id = mcr.mc_header_id
and mch.mc_id = mcp.mc_id
      and mch.version_number = nvl(mcp.version_number, mch.version_number)
      and mcr.position_key = mcp.position_key
      and mcp.sequence = (select max(sequence)
                          from ahl_mc_path_position_nodes where
                          path_position_id = nvl(c_relationship_id,-1)
                          and path_position_id=mcp.path_position_id)
      and mcp.path_position_id = nvl(c_relationship_id,-1)
      and mcr.item_group_id = igass.item_group_id
      and igass.INVENTORY_ITEM_ID = mtl.INVENTORY_ITEM_ID
      and igass.INVENTORY_ORG_ID = mtl.ORGANIZATION_ID
      and mtl.inventory_item_id=c_inventory_item_id
      and MTL.service_item_flag = 'N'
      and STAT.inventory_item_status_code = MTL.inventory_item_status_code
      and IT.lookup_code (+) = MTL.item_type
      and IT.lookup_type (+) = 'ITEM_TYPE'
      and trunc(sysdate) between trunc(nvl(it.start_date_active,sysdate))
      and trunc(nvl(IT.end_date_active,sysdate+1));

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_inventory_item_id IS NULL OR
       p_inventory_item_id = FND_API.G_MISS_NUM OR
       p_relationship_id IS NULL OR
       p_relationship_id = FND_API.G_MISS_NUM ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  OPEN check_alternate( p_relationship_id , p_inventory_item_id );

  FETCH check_alternate INTO
    l_dummy;

  IF check_alternate%NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_FMP_INVALID_POSITION_ITEM';
  END IF;

  CLOSE check_alternate;
  RETURN;

END validate_position_item;

PROCEDURE validate_counter_template
(
 x_return_status          OUT NOCOPY    VARCHAR2,
 x_msg_data               OUT NOCOPY    VARCHAR2,
 p_inventory_item_id      IN            NUMBER := NULL,
 p_relationship_id        IN            NUMBER := NULL,
 p_counter_name           IN            VARCHAR2 := NULL,
 p_x_counter_id           IN OUT NOCOPY NUMBER
)
IS

l_msg_data             VARCHAR2(2000);
l_return_status        VARCHAR2(1);
l_counter_id           NUMBER;
l_counter_group_id     NUMBER;
l_inventory_item_id    NUMBER;
--pdoki added for bug 6719371
l_dummy                VARCHAR2(1);
l_counter_valid_flag   BOOLEAN := FALSE;

CURSOR check_alternate_ctr_id(c_counter_id NUMBER, c_relationship_id NUMBER)
IS
SELECT 'X'
FROM   csi_counter_template_vl C,
       --CS_COUNTER_GROUPS CG,
       CS_CSI_COUNTER_GROUPS CG,
       CS_CTR_ASSOCIATIONS CA,
       AHL_POSITION_ALTERNATES_V PA
WHERE  C.DEFAULTED_GROUP_ID = CG.COUNTER_GROUP_ID
       AND CG.TEMPLATE_FLAG = 'Y'
       AND C.COUNTER_ID = c_counter_id
       AND C.DIRECTION IN ('A',
                           'B')
       AND CG.COUNTER_GROUP_ID = CA.COUNTER_GROUP_ID
       AND CA.SOURCE_OBJECT_ID = PA.INVENTORY_ITEM_ID
       AND PA.RELATIONSHIP_ID = c_relationship_id;


CURSOR get_rec_from_value ( c_counter_name VARCHAR2 )
IS
/*
SELECT DISTINCT C.counter_id,
                C.counter_group_id
FROM            CS_COUNTERS C, CS_COUNTER_GROUPS CG
WHERE           CG.template_flag = 'Y'
AND             C.counter_group_id = CG.counter_group_id
AND             C.name = c_counter_name
AND             C.DIRECTION in ('A','B'); */

--Priyan
--Performance tuning changes
--Refer Bug # 4913671

SELECT DISTINCT
  C.COUNTER_ID,
  C.DEFAULTED_GROUP_ID  COUNTER_GROUP_ID
FROM
  CSI_COUNTER_TEMPLATE_VL C,
  --CS_COUNTER_GROUPS CG
  --Priyan
  --Perf changes . Refer Bug # 4913671
  CS_CSI_COUNTER_GROUPS CG
WHERE
    CG.TEMPLATE_FLAG = 'Y'
  AND C.DEFAULTED_GROUP_ID   = CG.COUNTER_GROUP_ID
  AND C.NAME = c_counter_name
  AND C.DIRECTION in ('A','B');


-- NEED TO REQUEST CS TEAM TO ADD INDEX ON COUNTER_GROU_ID IN TABLE
CURSOR get_rec_from_id ( c_counter_id NUMBER )
IS
/*
SELECT DISTINCT C.counter_id,
                C.counter_group_id
FROM            CS_COUNTERS C, CS_COUNTER_GROUPS CG
WHERE           CG.template_flag = 'Y'
AND             C.counter_group_id = CG.counter_group_id
AND             C.counter_id = c_counter_id;
*/

--Priyan
--Performance tuning changes
--Refer Bug # 4913671

 SELECT DISTINCT
  C.COUNTER_ID,
  C.DEFAULTED_GROUP_ID  COUNTER_GROUP_ID
 FROM
  CSI_COUNTER_TEMPLATE_VL C,
  --CS_COUNTER_GROUPS CG
  --Priyan
  --Perf changes . Refer Bug # 4913671
  CS_CSI_COUNTER_GROUPS CG
 WHERE
    CG.TEMPLATE_FLAG = 'Y'
  AND C.DEFAULTED_GROUP_ID = CG.COUNTER_GROUP_ID
  AND C.COUNTER_ID = c_counter_id ;


CURSOR validate_item_ctr_id(c_counter_id NUMBER, c_inventory_item_id NUMBER)
IS
SELECT 'X'
FROM --cs_counters c,
csi_counter_template_vl C,
--cs_counter_groups CG,
CS_CSI_COUNTER_GROUPS CG,
cs_ctr_associations CA
where --C.counter_group_id = CG.counter_group_id
C.defaulted_group_id = CG.counter_group_id
and CG.template_flag = 'Y'
and C.COUNTER_ID = c_counter_id
and C.direction in ('A','B')
and CG.counter_group_id = CA.counter_group_id
and CA.source_object_id = c_inventory_item_id;


/*
SELECT DISTINCT source_object_id
FROM            CS_CTR_ASSOCIATIONS
WHERE           counter_group_id = c_counter_group_id;


CURSOR get_counter_item ( c_counter_group_id NUMBER )
IS
SELECT DISTINCT source_object_id
FROM            CS_CTR_ASSOCIATIONS
WHERE           counter_group_id = c_counter_group_id;
*/


BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (  p_counter_name IS NULL AND --amsriniv . changed OR to AND
       ( p_x_counter_id IS NULL OR
         p_x_counter_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_FMP_INVALID_COUNTER';
    RETURN;
  END IF;

  IF ( ( p_inventory_item_id IS NULL OR
         p_inventory_item_id = FND_API.G_MISS_NUM ) AND
       ( p_relationship_id IS NULL OR
         p_relationship_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_FMP_INVALID_CTR_ITEM';
    RETURN;
  END IF;

  IF ( ( p_counter_name IS NULL OR
         p_counter_name = FND_API.G_MISS_CHAR ) AND
       ( p_x_counter_id IS NOT NULL AND
         p_x_counter_id <> FND_API.G_MISS_NUM ) ) THEN

    IF ( p_inventory_item_id IS NOT NULL AND
         p_inventory_item_id <> FND_API.G_MISS_NUM ) THEN
       OPEN validate_item_ctr_id(p_x_counter_id, p_inventory_item_id);
       FETCH validate_item_ctr_id INTO l_dummy;
       IF (validate_item_ctr_id%NOTFOUND) THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_data := 'AHL_FMP_INVALID_CTR_ITEM';
       END IF;
       CLOSE validate_item_ctr_id;
    ELSIF (p_relationship_id IS NOT NULL AND
           p_relationship_id <> FND_API.G_MISS_NUM ) THEN
       OPEN check_alternate_ctr_id(p_x_counter_id, p_relationship_id);
       FETCH check_alternate_ctr_id INTO l_dummy;
       IF (check_alternate_ctr_id%NOTFOUND) THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         x_msg_data := 'AHL_FMP_INVALID_CTR_POSITION';
       END IF;
       CLOSE check_alternate_ctr_id;
    END IF;
  END IF;

  IF ( p_counter_name IS NOT NULL AND
       p_counter_name <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_counter_name );

    LOOP

      FETCH get_rec_from_value INTO
        l_counter_id,
        l_counter_group_id;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( p_inventory_item_id IS NOT NULL AND
           p_inventory_item_id <> FND_API.G_MISS_NUM ) THEN
         OPEN validate_item_ctr_id(l_counter_id, p_inventory_item_id);
         FETCH validate_item_ctr_id INTO l_dummy;
         IF (validate_item_ctr_id%FOUND) THEN
            l_counter_valid_flag := TRUE;
            p_x_counter_id := l_counter_id;
            CLOSE validate_item_ctr_id;
            EXIT;
         END IF;
         CLOSE validate_item_ctr_id;
      ELSIF (p_relationship_id IS NOT NULL AND
             p_relationship_id <> FND_API.G_MISS_NUM ) THEN
         OPEN check_alternate_ctr_id(l_counter_id, p_relationship_id);
         FETCH check_alternate_ctr_id INTO l_dummy;
         IF (check_alternate_ctr_id%FOUND) THEN
            l_counter_valid_flag := TRUE;
            p_x_counter_id := l_counter_id;
            CLOSE check_alternate_ctr_id;
            EXIT;
         END IF;
         CLOSE check_alternate_ctr_id;
      END IF;

    END LOOP;

    IF (get_rec_from_value%ROWCOUNT = 0) THEN --added by amsriniv
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_INVALID_COUNTER';
    ELSE
        IF NOT(l_counter_valid_flag)THEN
          IF ( p_inventory_item_id IS NOT NULL AND
               p_inventory_item_id <> FND_API.G_MISS_NUM ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_data := 'AHL_FMP_INVALID_CTR_ITEM';
          ELSIF ( p_relationship_id IS NOT NULL AND
                  p_relationship_id <> FND_API.G_MISS_NUM ) THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_data := 'AHL_FMP_INVALID_CTR_POSITION';
          END IF;
        END IF;
    END IF;
  END IF;

END validate_counter_template;

PROCEDURE validate_country
(
 x_return_status        OUT NOCOPY    VARCHAR2,
 x_msg_data             OUT NOCOPY    VARCHAR2,
 p_country_name         IN            VARCHAR2 := NULL,
 p_x_country_code       IN OUT NOCOPY VARCHAR2
)
IS

l_country_code      VARCHAR2(2);

CURSOR get_rec_from_value ( c_country_name VARCHAR2 )
IS
SELECT DISTINCT territory_code
FROM            FND_TERRITORIES_VL
WHERE           territory_short_name = c_country_name;

CURSOR get_rec_from_id ( c_country_code VARCHAR2 )
IS
SELECT DISTINCT territory_code
FROM            FND_TERRITORIES_VL
WHERE           territory_code = c_country_code;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_country_name IS NULL OR
         p_country_name = FND_API.G_MISS_CHAR ) AND
       ( p_x_country_code IS NULL OR
         p_x_country_code = FND_API.G_MISS_CHAR ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_country_name IS NULL OR
         p_country_name = FND_API.G_MISS_CHAR ) AND
       ( p_x_country_code IS NOT NULL AND
         p_x_country_code <> FND_API.G_MISS_CHAR ) ) THEN

    OPEN get_rec_from_id( p_x_country_code );

    FETCH get_rec_from_id INTO
      l_country_code;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_INVALID_COUNTRY';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_country_name IS NOT NULL AND
       p_country_name <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_country_name );

    LOOP
      FETCH get_rec_from_value INTO
        l_country_code;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_country_code = p_x_country_code ) THEN
        CLOSE get_rec_from_value;
        RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_INVALID_COUNTRY';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_country_code := l_country_code;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_TOO_MANY_COUNTRIES';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_country;

PROCEDURE validate_manufacturer
(
 x_return_status          OUT NOCOPY    VARCHAR2,
 x_msg_data               OUT NOCOPY    VARCHAR2,
 p_inventory_item_id      IN            NUMBER := NULL,
 p_relationship_id        IN            NUMBER := NULL,
 p_manufacturer_name      IN            VARCHAR2 := NULL,
 p_x_manufacturer_id      IN OUT NOCOPY NUMBER
)
IS

l_msg_data             VARCHAR2(2000);
l_return_status        VARCHAR2(1);
l_manufacturer_id      NUMBER;
l_inventory_item_id    NUMBER;

CURSOR get_rec_from_value ( c_manufacturer_name VARCHAR2 )
IS
/*SELECT DISTINCT manufacturer_id,
                inventory_item_id
FROM            MTL_MFG_PART_NUMBERS_ALL_V
WHERE           manufacturer_name = c_manufacturer_name;*/

--priyan
--Changing the query for performance reasons
--Refer Bug # 5078530

select distinct     b.manufacturer_id,
                    a.inventory_item_id
from                mtl_manufacturers b,
                    mtl_mfg_part_numbers a
where               a.manufacturer_id = b.manufacturer_id
and                 b.manufacturer_name = c_manufacturer_name
and                 a.organization_id in ( select distinct
                        m.master_organization_id
                      from inv_organization_info_v org,
                         mtl_parameters m
                      where org.organization_id = m.organization_id
                        and nvl(org.operating_unit, mo_global.get_current_org_id()) = mo_global.get_current_org_id() );


CURSOR get_rec_from_id ( c_manufacturer_id NUMBER )
IS
/*SELECT DISTINCT manufacturer_id,
                inventory_item_id
FROM            MTL_MFG_PART_NUMBERS_ALL_V
WHERE           manufacturer_id = c_manufacturer_id;*/

--priyan
--Changing the query for performance reasons
--Refer Bug # 5078530

select distinct     manufacturer_id,
                    inventory_item_id
from                mtl_mfg_part_numbers
where               manufacturer_id = c_manufacturer_id
and                 organization_id in ( select distinct
                        m.master_organization_id
                      from inv_organization_info_v org,
                        mtl_parameters m
                      where org.organization_id = m.organization_id
                        and nvl(org.operating_unit, mo_global.get_current_org_id()) = mo_global.get_current_org_id() );


BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_manufacturer_name IS NULL OR
         p_manufacturer_name = FND_API.G_MISS_CHAR ) AND
       ( p_x_manufacturer_id IS NULL OR
         p_x_manufacturer_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_inventory_item_id IS NULL OR
         p_inventory_item_id = FND_API.G_MISS_NUM ) AND
       ( p_relationship_id IS NULL OR
         p_relationship_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_manufacturer_name IS NULL OR
         p_manufacturer_name = FND_API.G_MISS_CHAR ) AND
       ( p_x_manufacturer_id IS NOT NULL AND
         p_x_manufacturer_id <> FND_API.G_MISS_NUM ) ) THEN

    OPEN get_rec_from_id( p_x_manufacturer_id );

    LOOP
      FETCH get_rec_from_id INTO
        l_manufacturer_id,
        l_inventory_item_id;

      EXIT WHEN get_rec_from_id%NOTFOUND;

      IF ( p_inventory_item_id IS NOT NULL AND
           p_inventory_item_id <> FND_API.G_MISS_NUM ) THEN
        IF ( p_inventory_item_id = l_inventory_item_id ) THEN
          CLOSE get_rec_from_id;
          RETURN;
        END IF;
      ELSIF ( p_relationship_id IS NOT NULL AND
              p_relationship_id <> FND_API.G_MISS_NUM ) THEN

        validate_position_item
        (
          x_return_status      => l_return_status,
          x_msg_data           => l_msg_data,
          p_inventory_item_id  => l_inventory_item_id,
          p_relationship_id    => p_relationship_id
        );

        IF ( NVL( l_return_status, 'X' ) = FND_API.G_RET_STS_SUCCESS ) THEN
          CLOSE get_rec_from_id;
          RETURN;
        END IF;
      END IF;

    END LOOP;

    IF ( get_rec_from_id%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_INVALID_MF';
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF ( p_inventory_item_id IS NOT NULL AND
           p_inventory_item_id <> FND_API.G_MISS_NUM ) THEN
        x_msg_data := 'AHL_FMP_INVALID_MF_ITEM';
      ELSIF ( p_relationship_id IS NOT NULL AND
              p_relationship_id <> FND_API.G_MISS_NUM ) THEN
        x_msg_data := 'AHL_FMP_INVALID_MF_POSITION';
      END IF;
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_manufacturer_name IS NOT NULL AND
       p_manufacturer_name <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_manufacturer_name );

    LOOP

      FETCH get_rec_from_value INTO
        l_manufacturer_id,
        l_inventory_item_id;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( p_inventory_item_id IS NOT NULL AND
           p_inventory_item_id <> FND_API.G_MISS_NUM ) THEN
        IF ( p_inventory_item_id = l_inventory_item_id ) THEN
          IF ( p_x_manufacturer_id IS NULL ) THEN
            p_x_manufacturer_id := l_manufacturer_id;
            CLOSE get_rec_from_value;
            RETURN;
          ELSIF ( l_manufacturer_id = p_x_manufacturer_id ) THEN
            CLOSE get_rec_from_value;
            RETURN;
          END IF;
        END IF;
      ELSIF ( p_relationship_id IS NOT NULL AND
              p_relationship_id <> FND_API.G_MISS_NUM ) THEN

        validate_position_item
        (
          x_return_status      => l_return_status,
          x_msg_data           => l_msg_data,
          p_inventory_item_id  => l_inventory_item_id,
          p_relationship_id    => p_relationship_id
        );

        IF ( NVL( l_return_status, 'X' ) = FND_API.G_RET_STS_SUCCESS ) THEN
          IF ( p_x_manufacturer_id IS NULL ) THEN
            p_x_manufacturer_id := l_manufacturer_id;
            CLOSE get_rec_from_value;
            RETURN;
          ELSIF ( l_manufacturer_id = p_x_manufacturer_id ) THEN
            CLOSE get_rec_from_value;
            RETURN;
          END IF;
        END IF;

      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_INVALID_MF';
    ELSE
      IF ( p_inventory_item_id IS NOT NULL AND
           p_inventory_item_id <> FND_API.G_MISS_NUM ) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := 'AHL_FMP_INVALID_MF_ITEM';
      ELSIF ( p_relationship_id IS NOT NULL AND
              p_relationship_id <> FND_API.G_MISS_NUM ) THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := 'AHL_FMP_INVALID_MF_POSITION';
      END IF;
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_manufacturer;

PROCEDURE validate_serial_numbers_range
(
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_serial_number_from           IN  VARCHAR2,
 p_serial_number_to             IN  VARCHAR2
)
IS

l_dummy            VARCHAR2(1);

CURSOR compare_numbers ( c_serial_number_from VARCHAR2 , c_serial_number_to VARCHAR2 )
IS
SELECT          'X'
FROM            DUAL
WHERE           TO_NUMBER( c_serial_number_to ) >=
                TO_NUMBER( c_serial_number_from );

CURSOR compare_chars ( c_serial_number_from VARCHAR2 , c_serial_number_to VARCHAR2 )
IS
SELECT          'X'
FROM            DUAL
WHERE           c_serial_number_to >= c_serial_number_from;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_serial_number_from IS NULL OR
       p_serial_number_from = FND_API.G_MISS_CHAR OR
       p_serial_number_to IS NULL OR
       p_serial_number_to = FND_API.G_MISS_CHAR ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  -- added numeric check to fix bug#9311242
  IF (sn_num(p_serial_number_from) AND sn_num(p_serial_number_to)) THEN
    BEGIN

      OPEN compare_numbers( p_serial_number_from, p_serial_number_to );

      FETCH compare_numbers INTO
        l_dummy;

      IF compare_numbers%NOTFOUND THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := 'AHL_FMP_INVALID_SERIAL_RANGE';
      END IF;

      CLOSE compare_numbers;

    EXCEPTION WHEN INVALID_NUMBER THEN
      IF compare_numbers%ISOPEN THEN
        CLOSE compare_numbers;
      END IF;

    -- added to fix bug#9311242
    WHEN OTHERS THEN
      IF compare_numbers%ISOPEN THEN
        CLOSE compare_numbers;
      END IF;
    END;

  END IF;

  OPEN compare_chars( p_serial_number_from, p_serial_number_to );

  FETCH compare_chars INTO
    l_dummy;

  IF compare_chars%NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_FMP_INVALID_SERIAL_RANGE';
  END IF;

  CLOSE compare_chars;
  RETURN;

END validate_serial_numbers_range;

PROCEDURE validate_mr_status
(
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_mr_header_id                 IN  NUMBER
)
IS
CURSOR check_mr_status( c_mr_header_id NUMBER )
IS
SELECT mr_status_code
FROM   AHL_MR_HEADERS_APP_V
WHERE  mr_header_id = c_mr_header_id;

l_mr_status_code    varchar2(30);
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF ( G_DEBUG = 'Y' ) THEN
    AHL_DEBUG_PUB.enable_debug;
    AHL_DEBUG_PUB.debug('Step A' );
  END IF;

  IF ( p_mr_header_id IS NULL OR
       p_mr_header_id = FND_API.G_MISS_NUM ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_FMP_MR_HEADER_ID_INVALID';
    RETURN;
  END IF;
    AHL_DEBUG_PUB.debug('Step A3' );
  OPEN check_mr_status( p_mr_header_id );

  FETCH check_mr_status INTO l_mr_status_code;

  IF check_mr_status%NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_FMP_INVALID_MR';
    CLOSE check_mr_status;
    RETURN;
  END IF;
    AHL_DEBUG_PUB.debug('Step A6' );
  IF ( l_mr_status_code <> 'DRAFT' AND
       l_mr_status_code <> 'APPROVAL_REJECTED' ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    AHL_DEBUG_PUB.debug('Step 1' );
    x_msg_data := 'AHL_FMP_INVALID_MR_STATUS';
    AHL_DEBUG_PUB.debug('Step 2' );
    CLOSE check_mr_status;
    RETURN;
  END IF;

  CLOSE check_mr_status;
  RETURN;

END validate_mr_status;

PROCEDURE validate_mr_effectivity
(
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_mr_effectivity_id            IN  NUMBER,
 p_object_version_number        IN  NUMBER := NULL
)
IS

l_object_version_number         NUMBER;

CURSOR check_mr_effectivity( c_mr_effectivity_id NUMBER )
IS
SELECT object_version_number
FROM   AHL_MR_EFFECTIVITIES_APP_V
WHERE  mr_effectivity_id = c_mr_effectivity_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_mr_effectivity_id IS NULL OR
       p_mr_effectivity_id = FND_API.G_MISS_NUM ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  OPEN check_mr_effectivity( p_mr_effectivity_id );

  FETCH check_mr_effectivity INTO
    l_object_version_number;

  IF check_mr_effectivity%NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_FMP_INVALID_MR_EFFECTIVITY';
    CLOSE check_mr_effectivity;
    RETURN;
  END IF;

  IF ( p_object_version_number IS NOT NULL OR
       p_object_version_number <> FND_API.G_MISS_NUM ) THEN
    IF ( p_object_version_number <> l_object_version_number ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_INVALID_MR_EFFECTIVITY';
    END IF;
  END IF;

  CLOSE check_mr_effectivity;
  RETURN;

END validate_mr_effectivity;

PROCEDURE validate_mr_interval_threshold
(
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_mr_header_id                 IN  NUMBER,
 p_repetitive_flag              IN  VARCHAR2
)
IS

l_msg_data            VARCHAR2(2000);
l_return_status       VARCHAR2(1);
l_dummy               VARCHAR2(1);
l_mr_effectivity_id   NUMBER;
l_counter_id          NUMBER;

CURSOR get_threshold( c_mr_header_id NUMBER )
IS
SELECT   'X'
FROM     AHL_MR_EFFECTIVITIES_APP_V
WHERE    mr_header_id = c_mr_header_id
AND      threshold_date IS NOT NULL;

CURSOR get_intervals( c_mr_header_id NUMBER )
IS
SELECT   A.mr_effectivity_id,
         A.counter_id
FROM     AHL_MR_INTERVALS_APP_V A, AHL_MR_EFFECTIVITIES_APP_V B
WHERE    A.mr_effectivity_id = B.mr_effectivity_id
AND      B.mr_header_id = c_mr_header_id
GROUP BY A.mr_effectivity_id,
         A.counter_id
HAVING   count(*) > 1;

CURSOR get_interval_range( c_mr_header_id NUMBER )
IS
SELECT   'X'
FROM     AHL_MR_INTERVALS_APP_V A, AHL_MR_EFFECTIVITIES_APP_V B
WHERE    ( A.start_date IS NOT NULL OR A.start_value IS NOT NULL )
AND      A.mr_effectivity_id = B.mr_effectivity_id
AND      B.mr_header_id = c_mr_header_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_mr_header_id IS NULL OR
         p_mr_header_id = FND_API.G_MISS_NUM ) AND
       ( p_repetitive_flag IS NULL OR
         p_repetitive_flag = FND_API.G_MISS_CHAR ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  -- Check if the Maintenance Requirement is in Updatable status
  AHL_FMP_COMMON_PVT.validate_mr_status
  (
    x_return_status        => l_return_status,
    x_msg_data             => l_msg_data,
    p_mr_header_id         => p_mr_header_id
  );

  IF ( NVL( l_return_status, 'X' ) <> FND_API.G_RET_STS_SUCCESS ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := l_msg_data;
    RETURN;
  END IF;

  IF ( p_repetitive_flag = 'Y' ) THEN
    OPEN get_threshold( p_mr_header_id );

    FETCH get_threshold INTO
      l_dummy;

    IF get_threshold%FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_INVALID_MR_THRESHOLD';
    END IF;

    CLOSE get_threshold;
    RETURN;
  ELSE
    OPEN get_intervals( p_mr_header_id );

    FETCH get_intervals INTO
      l_mr_effectivity_id,
      l_counter_id;

    IF get_intervals%FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_INVALID_MR_INTERVALS';
      CLOSE get_intervals;
      RETURN;
    END IF;

    CLOSE get_intervals;

    OPEN get_interval_range( p_mr_header_id );

    FETCH get_interval_range INTO
      l_dummy;

    IF get_interval_range%FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_INVALID_MR_INT_RANGE';
      CLOSE get_interval_range;
      RETURN;
    END IF;

    CLOSE get_interval_range;

  END IF;

END validate_mr_interval_threshold;




-----------------------------------------------------------------------
-- Start of Comments --
--  Procedure name    : Populate_Appl_MRs
--  Type        : Private
--  Function    : Calls FMP and populates the AHL_APPLICABLE_MRS table.
--  Pre-reqs    :
--  Parameters  :
--
--  Populate_Appl_MRs Parameters:
--       p_csi_ii_id       IN  csi item instance id  Required
--
--  Version :
--               Initial Version   1.0
--
--  End of Comments.


PROCEDURE Populate_Appl_MRs (
    p_csi_ii_id           IN            NUMBER,
    p_include_doNotImplmt IN            VARCHAR2 := 'Y',
    x_return_status       OUT  NOCOPY   VARCHAR2,
    x_msg_count           OUT  NOCOPY   NUMBER,
    x_msg_data            OUT  NOCOPY   VARCHAR2)
IS
 l_api_version     CONSTANT NUMBER := 1.0;
 l_appl_mrs_tbl    AHL_FMP_PVT.applicable_mr_tbl_type;

BEGIN

  -- Initialize temporary table.
  DELETE FROM AHL_APPLICABLE_MRS;

  -- call api to fetch all applicable mrs for ASO installation.
  AHL_FMP_PVT.get_applicable_mrs(
                           p_api_version            => l_api_version,
               p_init_msg_list          => FND_API.G_FALSE,
               p_commit                 => FND_API.G_FALSE,
               p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
                           x_return_status          => x_return_status,
                           x_msg_count              => x_msg_count,
                           x_msg_data               => x_msg_data,
               p_item_instance_id       => p_csi_ii_id,
               p_components_flag        => 'Y',
                           p_include_doNotImplmt    => p_include_doNotImplmt,
               x_applicable_mr_tbl      => l_appl_mrs_tbl);


  -- Raise errors if exceptions occur
  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
    RAISE FND_API.G_EXC_ERROR;
  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Populate temporary table ahl_applicable_mrs.
  IF (l_appl_mrs_tbl.COUNT > 0) THEN
     FOR i IN l_appl_mrs_tbl.FIRST..l_appl_mrs_tbl.LAST LOOP
     -- dbms_output.put_line( l_appl_mrs_tbl(i).item_instance_id||'  '||
     -- l_appl_mrs_tbl(i).mr_header_id);
           INSERT INTO AHL_APPLICABLE_MRS (
          CSI_ITEM_INSTANCE_ID,
          MR_HEADER_ID,
          MR_EFFECTIVITY_ID,
          REPETITIVE_FLAG   ,
          SHOW_REPETITIVE_CODE,
          COPY_ACCOMPLISHMENT_CODE,
          PRECEDING_MR_HEADER_ID,
            IMPLEMENT_STATUS_CODE,
          DESCENDENT_COUNT
           ) values
          ( l_appl_mrs_tbl(i).item_instance_id,
            l_appl_mrs_tbl(i).mr_header_id,
            l_appl_mrs_tbl(i).mr_effectivity_id,
            l_appl_mrs_tbl(i).repetitive_flag,
            l_appl_mrs_tbl(i).show_repetitive_code,
            l_appl_mrs_tbl(i).copy_accomplishment_flag,
            l_appl_mrs_tbl(i).preceding_mr_header_id,
            l_appl_mrs_tbl(i).implement_status_code,
            l_appl_mrs_tbl(i).descendent_count
        );
     END LOOP;
  END IF;

END Populate_Appl_MRs;

--------------------------------------------------------------------------------------------
-- API Name : Mr_Title_Version_To_Id
-- Purpose  : To get mr_header_id out of mr_title and mr_version_number
--------------------------------------------------------------------------------------------
PROCEDURE Mr_Title_Version_To_Id
(
  p_mr_title    IN    VARCHAR2,
  p_mr_version_number IN    NUMBER,
  x_mr_header_id  OUT NOCOPY  NUMBER,
  x_return_status   OUT NOCOPY  VARCHAR2
)
AS

-- Cursor for getting mr_header_id out of mr_title and mr_version_number
CURSOR header_id_csr_type(p_mr_title IN VARCHAR2, p_mr_version_number IN NUMBER) IS
SELECT mr_header_id
FROM ahl_mr_headers_app_v
WHERE title = p_mr_title
AND version_number = p_mr_version_number
AND  mr_status_code<>'TERMINATED'
AND TRUNC(NVL(effective_to,SYSDATE+1))> TRUNC(SYSDATE);


l_api_name  CONSTANT  VARCHAR2(30)  := 'Mr_Title_Version_To_Id';
l_api_version CONSTANT  NUMBER    := 1.0;
l_header_id NUMBER;

BEGIN
  x_return_status:=FND_API.G_RET_STS_SUCCESS;
  OPEN  header_id_csr_type(p_mr_title, p_mr_version_number);
  FETCH header_id_csr_type INTO l_header_id;
  CLOSE header_id_csr_type;
  IF l_header_id IS NULL THEN
  x_return_status:=FND_API.G_RET_STS_ERROR;
  FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_NOT_EXISTS');
  FND_MESSAGE.SET_TOKEN('TITLE', p_mr_title);
  FND_MESSAGE.SET_TOKEN('VERSION', p_mr_version_number);
  FND_MSG_PUB.ADD;
  IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)THEN
      fnd_log.string
      (
        fnd_log.level_error,
        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
        'MR Title and Version Number Combination is invalid'
      );
  END IF;
  ELSE
      x_mr_header_id :=   l_header_id;
  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)THEN
   fnd_log.string
   (
       fnd_log.level_statement,
      'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
       'x_mr_header_id--->'||x_mr_header_id
   );
  END IF;
  END IF;

END Mr_Title_Version_To_Id;

--------------------------------------------------------------------------------------------
-- API Name : Mr_Effectivity_Name_To_Id
-- Purpose  : To get mr_effectivity_id from mr_effectivity_name
--------------------------------------------------------------------------------------------

PROCEDURE Mr_Effectivity_Name_To_Id
(
  p_mr_header_id  IN    NUMBER,
  p_mr_effectivity_name IN      VARCHAR2,
  x_mr_effectivity_id   OUT NOCOPY    NUMBER,
  x_return_status   OUT NOCOPY  VARCHAR2
)
AS

CURSOR effectivity_id_csr_type(p_mr_effectivity_name IN VARCHAR2,
                               p_mr_header_id IN NUMBER)
IS
SELECT mr_effectivity_id
FROM ahl_mr_effectivities_app_v
WHERE name = p_mr_effectivity_name
      AND
      mr_header_id = p_mr_header_id;

l_api_name  CONSTANT  VARCHAR2(30)  := 'Mr_Effectivity_Name_To_Id';
l_api_version CONSTANT  NUMBER    := 1.0;
l_mr_effectivity_id NUMBER;

BEGIN
  x_return_status:=FND_API.G_RET_STS_SUCCESS;

  OPEN  effectivity_id_csr_type(p_mr_effectivity_name,p_mr_header_id);
  FETCH effectivity_id_csr_type INTO l_mr_effectivity_id;
  CLOSE effectivity_id_csr_type;
  IF l_mr_effectivity_id IS NULL THEN
  x_return_status:=FND_API.G_RET_STS_ERROR;
  FND_MESSAGE.SET_NAME('AHL','AHL_FMP_MR_EFFEC_NOT_EXISTS');
  FND_MESSAGE.SET_TOKEN('RECORD', p_mr_effectivity_name);
  FND_MSG_PUB.ADD;
  IF (fnd_log.level_error >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string
      (
        fnd_log.level_error,
        'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
        'MR Effectivity name specified is invalid'
      );
  END IF;
  ELSE
  x_mr_effectivity_id :=  l_mr_effectivity_id;
  IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
   fnd_log.string
   (
       fnd_log.level_statement,
      'ahl.plsql.'||g_pkg_name||'.'||l_api_name||':',
       'x_mr_effectivity_id--->'||x_mr_effectivity_id
   );
  END IF;

  END IF;

END Mr_Effectivity_Name_To_Id;


FUNCTION check_mr_type
(p_mr_header_id IN NUMBER) RETURN  varchar2  IS
l_activity varchar2(30);
cursor l_check_mr_type_csr (c_mr_header_id IN NUMBER)
is
SELECT TYPE_CODE
FROM   AHL_MR_HEADERS_B
WHERE  mr_header_id = c_mr_header_id;
begin
               open l_check_mr_type_csr(p_mr_header_id);
               FETCH  l_check_mr_type_csr INTO l_activity;

if l_check_mr_type_csr%NOTFOUND THEN
    l_activity  :=NULL;
END IF;
CLOSE l_check_mr_type_csr ;
return l_activity;
end check_mr_type;



FUNCTION check_mr_status
(p_mr_header_id IN NUMBER) RETURN  varchar2  IS
l_status varchar2(30);
cursor l_check_mr_status_csr (c_mr_header_id IN NUMBER)
is
SELECT mr_status_code
FROM   AHL_MR_HEADERS_B
WHERE  mr_header_id = c_mr_header_id
AND trunc(nvl( effective_to, sysdate+1 ))>=trunc(sysdate);
begin
               open l_check_mr_status_csr(p_mr_header_id);
               FETCH  l_check_mr_status_csr INTO l_status;

if l_check_mr_status_csr%NOTFOUND THEN
    l_status  :=NULL;
END IF;
CLOSE l_check_mr_status_csr ;
return l_status;
end check_mr_status;


PROCEDURE validate_mr_pm_status
(
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_mr_header_id                 IN  NUMBER
)
IS

l_mr_status_code        VARCHAR2(30);

CURSOR check_mr_status( c_mr_header_id NUMBER )
IS
SELECT mr_status_code
FROM   AHL_MR_HEADERS_B
WHERE  mr_header_id = c_mr_header_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_mr_header_id IS NULL OR
       p_mr_header_id = FND_API.G_MISS_NUM ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  OPEN check_mr_status( p_mr_header_id );

  FETCH check_mr_status INTO
    l_mr_status_code;

  IF check_mr_status%NOTFOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_FMP_INVALID_MR';
    CLOSE check_mr_status;
    RETURN;
  END IF;

  IF ( l_mr_status_code <> 'DRAFT' AND
       l_mr_status_code <> 'APPROVAL_REJECTED' AND
       l_mr_status_code <> 'COMPLETE'
       ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_FMP_INVALID_MR_STATUS';
    CLOSE check_mr_status;
    RETURN;
  END IF;

  CLOSE check_mr_status;
  RETURN;

END validate_mr_pm_status;


PROCEDURE validate_mr_type_program
(
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_mr_header_id                 IN  NUMBER,
 p_effectivity_id               IN  NUMBER,
 p_eff_obj_version              IN  NUMBER
)
IS

l_record_exists        NUMBER;

CURSOR mr_type_program( c_effectivity_id NUMBER,c_eff_obj number,c_mr_header_id number)
IS
SELECT 1
FROM DUAL
WHERE
EXISTS (
        SELECT 'x'
        FROM AHL_UNIT_EFFECTIVITIES_B unit,
             CSI_ITEM_INSTANCES csi,
             AHL_MR_EFFECTIVITIES eff
        where
            eff.inventory_item_id         = csi.INVENTORY_ITEM_ID
        and unit.CSI_ITEM_INSTANCE_ID     = csi.instance_id
        and unit.program_mr_header_id     = c_mr_header_id
        and eff.mr_effectivity_id         =c_effectivity_id
        and eff.object_version_number     =c_eff_obj ) ;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( p_mr_header_id IS NULL OR
       p_mr_header_id = FND_API.G_MISS_NUM ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  OPEN mr_type_program( p_effectivity_id, p_eff_obj_version, p_mr_header_id );
  FETCH mr_type_program INTO l_record_exists;

  IF mr_type_program%FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_FMP_EFFECTIVITY_ITEM_PM';
  END IF;

  CLOSE mr_type_program;

END validate_mr_type_program;



PROCEDURE validate_mr_type_activity
(
 x_return_status                OUT NOCOPY VARCHAR2,
 x_msg_data                     OUT NOCOPY VARCHAR2,
 p_effectivity_id               IN  NUMBER,
 p_eff_obj_version              IN  NUMBER
)
IS

l_record_exists        NUMBER;

CURSOR mr_type_activity( c_effectivity_id NUMBER,c_eff_obj number)
IS
SELECT 1
FROM DUAL
WHERE EXISTS ( SELECT 'x'
               FROM AHL_UNIT_EFFECTIVITIES_B unit,
                    CSI_ITEM_INSTANCES csi,
                    AHL_MR_EFFECTIVITIES eff
               where
                   eff.inventory_item_id         = csi.INVENTORY_ITEM_ID
               and unit.CSI_ITEM_INSTANCE_ID     = csi.instance_id
               and unit.mr_header_id   =eff.mr_header_id
               and eff.mr_effectivity_id =c_effectivity_id
               and eff.object_version_number=c_eff_obj) ;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  OPEN mr_type_activity( p_effectivity_id, p_eff_obj_version);
  FETCH mr_type_activity INTO l_record_exists;

  IF mr_type_activity%FOUND THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_FMP_EFFECTIVITY_ITEM_PM';
  END IF;

  CLOSE mr_type_activity;

END validate_mr_type_activity;

-- Start of Comments
-- Procedure name              : validate_owner
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_owner IN parameters:
--      p_inventory_item_id         NUMBER     Default NULL
--      p_relationship_id           NUMBER     Default NULL
--       p_owner         VARCHAR2   Default NULL
--
-- validate_manufacturer IN OUT parameters:
--      p_x_owner_id         NUMBER
--
-- validate_manufacturer OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE validate_owner
(
 x_return_status          OUT NOCOPY    VARCHAR2,
 x_msg_data               OUT NOCOPY    VARCHAR2,
 p_owner                  IN            VARCHAR2 := NULL,
 p_x_owner_id             IN OUT NOCOPY NUMBER
) IS
l_msg_data             VARCHAR2(2000);
l_return_status        VARCHAR2(1);
l_owner_id      NUMBER;


CURSOR get_owner_rec_from_value ( c_owner VARCHAR2)
IS
select DISTINCT  OWN.owner_id
from ahl_owner_details_v OWN
where upper(owner_name) like upper(c_owner);


CURSOR get_owner_rec_from_id ( c_owner_id NUMBER)
IS
select DISTINCT  OWN.owner_id
from ahl_owner_details_v OWN
where owner_id =  c_owner_id;

CURSOR get_owner_rec_from_id_val ( c_owner_id NUMBER,c_owner VARCHAR2)
IS
select DISTINCT  OWN.owner_id
from ahl_owner_details_v OWN
where owner_id =  c_owner_id
and upper(owner_name) like upper(c_owner);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_owner IS NULL OR
         p_owner = FND_API.G_MISS_CHAR ) AND
       ( p_x_owner_id IS NULL OR
         p_x_owner_id = FND_API.G_MISS_NUM ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;


  IF ( ( p_owner IS NULL OR
         p_owner = FND_API.G_MISS_CHAR ) AND
       ( p_x_owner_id IS NOT NULL AND
         p_x_owner_id <> FND_API.G_MISS_NUM ) ) THEN

    OPEN get_owner_rec_from_id( p_x_owner_id );

    LOOP
      FETCH get_owner_rec_from_id INTO
        l_owner_id;
      EXIT WHEN get_owner_rec_from_id%NOTFOUND;
    END LOOP;

    IF ( get_owner_rec_from_id%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_INVALID_OWNER';
    ELSIF ( get_owner_rec_from_id%ROWCOUNT = 1 ) THEN
      p_x_owner_id := l_owner_id;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_INV_TOO_MANY_OWNERS';
    END IF;
    CLOSE get_owner_rec_from_id;

  ELSIF ( p_owner IS NOT NULL AND
       p_owner <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_owner_rec_from_value( p_owner );

    LOOP

      FETCH get_owner_rec_from_value INTO
        l_owner_id;
      EXIT WHEN get_owner_rec_from_value%NOTFOUND;

    END LOOP;
    IF ( get_owner_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_INVALID_OWNER';
    ELSIF ( get_owner_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_owner_id := l_owner_id;
    ELSIF  ( get_owner_rec_from_value%ROWCOUNT > 1 ) THEN
      IF( p_x_owner_id IS NOT NULL AND
         p_x_owner_id <> FND_API.G_MISS_NUM ) THEN

         OPEN get_owner_rec_from_id_val( p_x_owner_id,p_owner );

	 LOOP
	       FETCH get_owner_rec_from_id_val INTO
	         l_owner_id;
	       EXIT WHEN get_owner_rec_from_id_val%NOTFOUND;
	 END LOOP;

	 IF ( get_owner_rec_from_id_val%ROWCOUNT = 0 ) THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    x_msg_data := 'AHL_FMP_INVALID_OWNER';
	 ELSIF ( get_owner_rec_from_id_val%ROWCOUNT = 1 ) THEN
	    p_x_owner_id := l_owner_id;
	 ELSE
	    x_return_status := FND_API.G_RET_STS_ERROR;
	    x_msg_data := 'AHL_FMP_INV_TOO_MANY_OWNERS';
	 END IF;
         CLOSE get_owner_rec_from_id_val;

      ELSE
        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := 'AHL_FMP_INV_TOO_MANY_OWNERS';
      END IF;
    END IF;
    CLOSE get_owner_rec_from_value;

  END IF;

END validate_owner;

-- Start of Comments
-- Procedure name              : validate_location
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_country IN parameters:
--      p_location              VARCHAR2   Default NULL
--
-- validate_location IN OUT parameters:
--      p_x_location_type_code            VARCHAR2
--
-- validate_country OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE validate_location
(
 x_return_status        OUT NOCOPY    VARCHAR2,
 x_msg_data             OUT NOCOPY    VARCHAR2,
 p_location         IN            VARCHAR2 := NULL,
 p_x_location_type_code       IN OUT NOCOPY VARCHAR2
)IS
l_location_type_code      VARCHAR2(30);

CURSOR get_rec_from_value ( c_location VARCHAR2 )
IS
select lookup_code from csi_lookups
where lookup_type='CSI_INST_LOCATION_SOURCE_CODE'
and upper(meaning) like upper(c_location);

CURSOR get_rec_from_id ( c_location_type_code VARCHAR2 )
IS
select lookup_code from csi_lookups
where lookup_type='CSI_INST_LOCATION_SOURCE_CODE'
and lookup_code = c_location_type_code;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_location IS NULL OR
         p_location = FND_API.G_MISS_CHAR ) AND
       ( p_x_location_type_code IS NULL OR
         p_x_location_type_code = FND_API.G_MISS_CHAR ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_location IS NULL OR
         p_location = FND_API.G_MISS_CHAR ) AND
       ( p_x_location_type_code IS NOT NULL AND
         p_x_location_type_code <> FND_API.G_MISS_CHAR ) ) THEN

    OPEN get_rec_from_id( p_x_location_type_code );

    FETCH get_rec_from_id INTO
      l_location_type_code;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_INVALID_LOCATION';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_location IS NOT NULL AND
       p_location <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_location );

    LOOP
      FETCH get_rec_from_value INTO
        l_location_type_code;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_location_type_code = p_x_location_type_code ) THEN
        CLOSE get_rec_from_value;
        RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_INVALID_LOCATION';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_location_type_code := l_location_type_code;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_TOO_MANY_LOCATIONS';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_location;

-- Start of Comments
-- Procedure name              : validate_csi_ext_attribute
-- Type                        : Private
-- Pre-reqs                    :
-- Function                    :
-- Parameters                  :
--
-- Standard IN  Parameters :
--      None
--
-- Standard OUT Parameters :
--      x_return_status             VARCHAR2   Required
--      x_msg_data                  VARCHAR2   Required
--
-- validate_country IN parameters:
--      p_csi_attribute_name              VARCHAR2   Default NULL
--
-- validate_country IN OUT parameters:
--      p_x_csi_attribute_code            VARCHAR2
--
-- validate_csi_ext_attribute OUT parameters:
--      None.
--
--
-- Version :
--          Current version        1.0
--
-- End of Comments

PROCEDURE validate_csi_ext_attribute
(
 x_return_status        OUT NOCOPY    VARCHAR2,
 x_msg_data             OUT NOCOPY    VARCHAR2,
 p_csi_attribute_name         IN            VARCHAR2 := NULL,
 p_x_csi_attribute_code       IN OUT NOCOPY VARCHAR2
)IS
l_csi_attribute_code      VARCHAR2(30);

CURSOR get_rec_from_value ( c_csi_attribute_name VARCHAR2 )
IS
select distinct CIEA.ATTRIBUTE_CODE from CSI_I_EXTENDED_ATTRIBS CIEA
where upper(attribute_name) like upper(c_csi_attribute_name);

CURSOR get_rec_from_id ( c_csi_attribute_code VARCHAR2 )
IS
select distinct CIEA.ATTRIBUTE_CODE from CSI_I_EXTENDED_ATTRIBS CIEA
where CIEA.ATTRIBUTE_CODE = c_csi_attribute_code;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF ( ( p_csi_attribute_name IS NULL OR
         p_csi_attribute_name = FND_API.G_MISS_CHAR ) AND
       ( p_x_csi_attribute_code IS NULL OR
         p_x_csi_attribute_code = FND_API.G_MISS_CHAR ) ) THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'AHL_COM_INVALID_PROCEDURE_CALL';
    RETURN;
  END IF;

  IF ( ( p_csi_attribute_name IS NULL OR
         p_csi_attribute_name = FND_API.G_MISS_CHAR ) AND
       ( p_x_csi_attribute_code IS NOT NULL AND
         p_x_csi_attribute_code <> FND_API.G_MISS_CHAR ) ) THEN

    OPEN get_rec_from_id( p_x_csi_attribute_code );

    FETCH get_rec_from_id INTO
      l_csi_attribute_code;

    IF get_rec_from_id%NOTFOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_INVALID_EXT_ATTR';
    END IF;

    CLOSE get_rec_from_id;
    RETURN;

  END IF;

  IF ( p_csi_attribute_name IS NOT NULL AND
       p_csi_attribute_name <> FND_API.G_MISS_CHAR ) THEN

    OPEN get_rec_from_value( p_csi_attribute_name );

    LOOP
      FETCH get_rec_from_value INTO
        l_csi_attribute_code;

      EXIT WHEN get_rec_from_value%NOTFOUND;

      IF ( l_csi_attribute_code = p_x_csi_attribute_code ) THEN
        CLOSE get_rec_from_value;
        RETURN;
      END IF;

    END LOOP;

    IF ( get_rec_from_value%ROWCOUNT = 0 ) THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_INVALID_EXT_ATTR';
    ELSIF ( get_rec_from_value%ROWCOUNT = 1 ) THEN
      p_x_csi_attribute_code := l_csi_attribute_code;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_data := 'AHL_FMP_TOO_MANY_EXT_ATTRS';
    END IF;

    CLOSE get_rec_from_value;
    RETURN;

  END IF;

END validate_csi_ext_attribute;

-- Check to see whether a VARCHAR2 contains only numeric values
FUNCTION sn_num(
  p_serial_number                IN    VARCHAR2
) RETURN BOOLEAN IS
  i                              NUMBER  := 0;

BEGIN
  LOOP
    i := i+1;
    EXIT WHEN SUBSTR(p_serial_number,-i,1) NOT IN ('0','1','2','3','4','5','6','7','8','9')
              OR i > LENGTH(p_serial_number);
  END LOOP;
  IF i = LENGTH(p_serial_number) + 1 THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END sn_num;

END AHL_FMP_COMMON_PVT;

/
