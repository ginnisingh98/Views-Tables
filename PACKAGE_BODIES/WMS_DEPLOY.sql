--------------------------------------------------------
--  DDL for Package Body WMS_DEPLOY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_DEPLOY" AS
/* $Header: WMSDEPLB.pls 120.0.12010000.12 2010/01/25 14:35:33 abasheer noship $ */

-- Global constant holding package name
g_pkg_name constant varchar2(50) := 'WMS_DEPLOY';
-- g_item_flex_delimiter caches the item flexfield delimiter
g_item_flex_delimiter VARCHAR2(2);
-- g_item_segment_count caches the count of item flexfield segments
g_item_segment_count NUMBER;
--g_item_id caches the item_id passed to function get_client_code
g_item_id NUMBER;
--g_client_code caches the ct code of g_item_id.
g_client_code  mtl_client_parameters.client_code%TYPE;


/* function returns the deployment mode based on the profile WMS_DEPLOYMENT_MODE
 * 'I' - Integrated Deployment
 * 'D' - Distributed (Standalone) Deployment
 * 'L' - LSP Deployment
*/
FUNCTION wms_deployment_mode RETURN VARCHAR2
IS
BEGIN
  IF WMS_DEPLOY.g_wms_deployment_mode IS NULL THEN

    CASE NVL(FND_PROFILE.VALUE('WMS_DEPLOYMENT_MODE'), 1)
      WHEN 1 THEN g_wms_deployment_mode := 'I'; -- Integrated Mode
      WHEN 2 THEN g_wms_deployment_mode := 'D'; -- Distributed Mode
      WHEN 3 THEN g_wms_deployment_mode := 'L'; -- LSP Mode
      ELSE g_wms_deployment_mode := 'I';
    END CASE;
  END IF;

  RETURN g_wms_deployment_mode;
END wms_deployment_mode;

FUNCTION get_item_flex_delimiter
  RETURN VARCHAR2 AS
BEGIN
  IF g_item_flex_delimiter IS NULL THEN
    BEGIN
      SELECT concatenated_segment_delimiter
      INTO g_item_flex_delimiter
      FROM fnd_id_flex_structures_vl
      WHERE (application_id=401)
      AND (id_flex_code    ='MSTK');
    EXCEPTION
      WHEN OTHERS THEN
        g_item_flex_delimiter := NULL;
    END;
  END IF;
  RETURN g_item_flex_delimiter;
END get_item_flex_delimiter;


FUNCTION get_item_flex_segment_count
  RETURN NUMBER AS
BEGIN
  IF g_item_segment_count IS NULL THEN
    BEGIN
      SELECT count(1)
      INTO g_item_segment_count
      FROM fnd_id_flex_segments_vl
      WHERE (id_flex_num =101)
      AND (id_flex_code  ='MSTK')
      AND (application_id=401);
    EXCEPTION
      WHEN OTHERS THEN
        g_item_segment_count := 0;
    END;
  END IF;
  RETURN g_item_segment_count;
END get_item_flex_segment_count;

/* function returns whether the item / transaction can be costed or not (Y/N)
 * Takes input a record structure with inventory_item_id and organization_id
*/
FUNCTION Costed_Txn (p_in_txn_rec IN t_in_txn_rec) RETURN VARCHAR2
IS
  costed_flag VARCHAR2(1) := 'Y';
BEGIN
  CASE wms_deployment_mode
    WHEN 'I' THEN         -- for Integration mode, always return 'Y'
      RETURN costed_flag;
    WHEN 'D' THEN         -- for Distributed mode, transactions should never be costed
      costed_flag := 'N';
     RETURN costed_flag;
    WHEN 'L' THEN        -- for LSP mode check for Item Costed/Invoiced flag and (Outsourcer Definition)
     BEGIN
       SELECT 'N'
       INTO   costed_flag
       FROM   mtl_system_items
       WHERE  inventory_item_id = p_in_txn_rec.inventory_item_id
       AND    organization_id = p_in_txn_rec.organization_id
       AND    costing_enabled_flag = 'N'
       AND    invoiceable_item_flag = 'N';
     EXCEPTION WHEN OTHERS THEN
       costed_flag := 'Y';
     END;
     RETURN costed_flag;
  END CASE;
END Costed_Txn;

/* Wrapper of Costed_Txn to obtain whether the item / transaction can be costed or not (Y/N)
 * given Item_id and Org_id
*/
FUNCTION Costed_Txn_For_Item (p_organization_id         NUMBER,
                              p_inventory_item_id       NUMBER
                              ) RETURN VARCHAR2 IS
    l_in_txn_rec        t_in_txn_rec;
BEGIN

    l_in_txn_rec.inventory_item_id := p_inventory_item_id;
    l_in_txn_rec.organization_id := p_organization_id;

    RETURN (Costed_Txn (l_in_txn_rec));

END;

/* procedure returns the outsourcer/client information pertaining to transaction details provided
 * Takes input a record structure with inventory_item_id and organization_id
 */
procedure Get_Client_Info ( p_in_txn_rec    IN         t_in_txn_rec,
                            x_client_rec    OUT NOCOPY t_client_rec,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2
                          ) IS

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  CASE wms_deployment_mode
    WHEN 'I' THEN
      x_client_rec.client_id   := NULL;
      x_client_rec.client_name := NULL;
    WHEN 'D' THEN
      x_client_rec.client_id   := NULL;
      x_client_rec.client_name := NULL;
    WHEN 'L' THEN
      x_client_rec.client_id   := NULL;
      x_client_rec.client_name := NULL;
  END CASE;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name, 'Get_Client_Info');
      END IF;
END Get_Client_Info;



/* Wrapper of Get_Client_Info to obtain Outsourcer_id for a
 * given Item_id and Org_id
*/
procedure Get_Client_Info_For_Item (x_return_status         OUT NOCOPY VARCHAR2,
                                    x_msg_count             OUT NOCOPY NUMBER,
                                    x_msg_data              OUT NOCOPY VARCHAR2,
                                    p_organization_id                  NUMBER,
                                    p_inventory_item_id                NUMBER,
                                    x_outsourcer_id         OUT NOCOPY NUMBER
                                   ) IS
    l_in_txn_rec        t_in_txn_rec;
    l_client_rec        t_client_rec;

BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_in_txn_rec.inventory_item_id := p_inventory_item_id;
    l_in_txn_rec.organization_id := p_organization_id;

    Get_Client_Info(l_in_txn_rec, l_client_rec, x_return_status, x_msg_count, x_msg_data);

    x_outsourcer_id := l_client_rec.client_id;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name, 'Get_Client_Info_For_Item');
      END IF;

END;



/* Returns the Item Category Id for a given outsourcer_id
*/
procedure Get_Category_Info (x_return_status        OUT NOCOPY VARCHAR2,
                             x_msg_count            OUT NOCOPY NUMBER,
                             x_msg_data             OUT NOCOPY VARCHAR2,
                             p_outsourcer_id                   NUMBER,
                             x_item_category_id     OUT NOCOPY NUMBER
                            )IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  CASE wms_deployment_mode
    WHEN 'I' THEN
      x_item_category_id   := NULL;     --API will not return anything in Integrated Mode
    WHEN 'D' THEN
      x_item_category_id   := NULL;     --API will not return anything in Distributed Mode
    WHEN 'L' THEN
      x_item_category_id   := NULL;     --API will return the Item Category Id stored in the Outcourcer schema
  END CASE;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name, 'Get_Category_Info');
      END IF;
END;

/* ==================================================================================*
 | Function : get_client_code returns the client code for the Item ID               |
 |            Added for LSP Project                                                 |
 |                                                                                  |
 | Description : For getting the client code  , to be used internally by Inventory  |
 |               team and shipping team                                             |
 | Input Parameters:                                                                |
 |   p_item_id         -    The item ID for which the client code is needed         |
 *================================================================================== */

 FUNCTION get_client_code
    ( p_item_id NUMBER)
    RETURN VARCHAR2
  as
    l_delimiter    VARCHAR2(1);
    l_client_code  mtl_client_parameters.client_code%TYPE := NULL;
    l_item_name    mtl_system_items_b_kfv.concatenated_segments%TYPE;
  begin
    IF wms_deployment_mode = 'L' THEN
     IF g_item_id = p_item_id  THEN
      -- returned the cached value
      RETURN g_client_code;
     ELSE

      Begin
        select concatenated_segments
        into l_item_name
        from mtl_system_items_b_kfv
        where inventory_item_id=p_item_id
        and rownum < 2;
      Exception
          when others then
            l_item_name:=null;
      End;
      If l_item_name is not null then
        l_delimiter := get_item_flex_delimiter;

        if l_delimiter is not null THEN
          IF (instr(l_item_name,l_delimiter,-1) <> 0) THEN
            l_client_code  := substr(l_item_name, instr(l_item_name,l_delimiter,-1)+1);
            -- cache the value for next run
            g_client_code := l_client_code;
	    g_item_id     := p_item_id;
            return l_client_code;
          END IF;
        end if;
      end if;
     END if; -- end IF g_item_id = p_item_id
    end if;  --end if wms_deployment_mode = 'L'
    return l_client_code;
  END get_client_code;

/* ==================================================================================*
 | Procedure : get_client_details                                                   |
 |              Added for LSP Project                                               |
 |                                                                                  |
 | Description : To validate passed client id, code and return name also,           |
 |               to be used by Shipping Team                                        |
 | Input Parameters:                                                                |
 |   x_client_id         -  The client ID for which the details needs to be passed  |
 |   x_client_code       -  The client Code for which the details needs to be passed|
 | Output Parameters:                                                               |
 |   x_return_status     - fnd_api.g_ret_sts_success, if succeeded                  |
 |                          fnd_api.g_ret_sts_error, if  error occurred             |
 |   x_client_id         -  The client ID for which the details needs to be passed  |
 |   x_client_code       -  The client Code for which the details needs to be passed|
 |   x_client_name       -  The client name corresponding to client ID fetched from |
 |                            hz_parties                                            |
 *================================================================================== */


  PROCEDURE get_client_details
      (
          x_client_id            IN   OUT NOCOPY MTL_CLIENT_PARAMETERS.CLIENT_ID%TYPE
        , x_client_code          IN   OUT NOCOPY MTL_CLIENT_PARAMETERS.CLIENT_CODE%TYPE
        , x_client_name          OUT NOCOPY HZ_PARTIES.PARTY_NAME%TYPE
        , x_return_status        OUT NOCOPY VARCHAR2
      )as

  BEGIN
      x_return_status := fnd_api.g_ret_sts_success;

      BEGIN

          IF x_client_id <> FND_API.G_MISS_NUM
            THEN
              BEGIN
                  SELECT client_id , client_code
                  INTO x_client_id , x_client_code
                  FROM mtl_client_parameters
                  WHERE client_id = x_client_id;
              END;
          ELSIF x_client_code <> FND_API.G_MISS_CHAR
            THEN
              BEGIN
                SELECT client_id , client_code
                INTO x_client_id , x_client_code
                FROM mtl_client_parameters
                WHERE client_code = x_client_code;
            END;
          ELSE
            RAISE fnd_api.g_exc_error;
          End IF;

          BEGIN
            SELECT client.party_name
            INTO x_client_name
            FROM hz_parties client, hz_cust_accounts cust_account
            WHERE  client.party_id = cust_account.party_id
            AND cust_account.cust_account_id = x_client_id;
          END;

      EXCEPTION
        WHEN OTHERS THEN
          x_return_status  := fnd_api.g_ret_sts_error;
      END;

  END get_client_details;

  FUNCTION get_client_item
    (
      p_org_id  NUMBER,
      p_item_id NUMBER)
    RETURN VARCHAR2 AS
    l_delimiter    VARCHAR2(1);
    l_item_name    VARCHAR2(800);
  BEGIN
    BEGIN
      SELECT concatenated_segments
      INTO   l_item_name
      FROM   mtl_system_items_b_kfv
      WHERE  inventory_item_id = p_item_id
      AND    organization_id   = p_org_id;
    EXCEPTION
      WHEN OTHERS THEN
        l_item_name := NULL;
    END;
    IF wms_deployment_mode='L' THEN
      IF l_item_name       IS NOT NULL THEN
        l_delimiter := get_item_flex_delimiter;
        IF l_delimiter IS NOT NULL THEN
          l_item_name  := SUBSTR(l_item_name, 1, INSTR(l_item_name,l_delimiter,-1)-1);
        END IF;
      END IF;
    END IF;
    RETURN l_item_name;
  END get_client_item;

  FUNCTION get_item_client_name( p_item_id NUMBER)
    RETURN VARCHAR2 AS
    l_client_id mtl_client_parameters.client_id%TYPE;
    l_client_code mtl_client_parameters.client_code%TYPE;
    l_client_name varchar2(360);
    l_return_status VARCHAR2(1);
  BEGIN
    IF wms_deployment_mode='L' THEN
      IF p_item_id IS NOT NULL THEN
        l_client_code:=get_client_code(p_item_id);
        get_client_details(l_client_id,l_client_code,l_client_name,l_return_status);
      END IF;
    END IF;
    RETURN l_client_name;
  END get_item_client_name;

  FUNCTION get_item_suffix_for_lov(p_concatenated_segments VARCHAR2)
    RETURN VARCHAR2 AS
      l_append    varchar(2):='';
      l_delimiter varchar2(1);
      l_segcount  number(2);
  BEGIN
    IF wms_deployment_mode ='L' THEN
      l_delimiter := get_item_flex_delimiter;
      l_segcount  := get_item_flex_segment_count;
      IF (LENGTH(p_concatenated_segments)-LENGTH(REPLACE(p_concatenated_segments,l_delimiter,''))) < (l_segcount -1) THEN
        l_append := l_delimiter||'%';
      ELSE
        l_append := '';
      END IF;
    END IF;
    RETURN l_append;
  END get_item_suffix_for_lov;

  FUNCTION get_po_client_code(p_po_header_id NUMBER)
    RETURN VARCHAR2 AS
    l_po_name        po_headers_all.segment1%TYPE;
    l_client_code    mtl_client_parameters.client_code%TYPE := NULL;
    l_delimiter      VARCHAR2(1) := '-' ;
    l_item_name      VARCHAR2(800);
  BEGIN
    BEGIN
      SELECT segment1
      INTO   l_po_name
      FROM   po_headers_all
      WHERE  po_header_id = p_po_header_id;

    EXCEPTION
      WHEN OTHERS THEN
      l_po_name := NULL;
    END;

    IF wms_deployment_mode='L' then
      IF l_po_name IS NOT NULL THEN
        /* Bug 9255222: Deriving l_delimiter from Item KFF */

        l_delimiter := get_item_flex_delimiter;

        IF l_delimiter IS NOT NULL THEN
          IF INSTR(l_po_name,l_delimiter,-1) <> 0 THEN
            l_client_code  := SUBSTR(l_po_name, INSTR(l_po_name,l_delimiter,-1)+1);
          END IF;
        END IF;
      END IF;
    END IF;
    RETURN l_client_code;
  END get_po_client_code;


  FUNCTION get_po_client_name(p_po_header_id number)
    RETURN VARCHAR2  AS
    l_client_id         mtl_client_parameters.client_id%TYPE;
    l_client_code       mtl_client_parameters.client_code%TYPE;
    l_client_name       VARCHAR2(360):='';
    l_return_status VARCHAR2(1);
  BEGIN
    IF wms_deployment_mode='L' THEN
      IF p_po_header_id IS NOT NULL THEN
        l_client_code := get_po_client_code(p_po_header_id);
        get_client_details(l_client_id,l_client_code,l_client_name,l_return_status);
      END IF;
    END IF;
    RETURN l_client_name;
  END get_po_client_name;

/* End of changes for LSP Project */

/* Changes for LSP Integration project */
procedure Get_Client_Item_Name ( x_item_id   NUMBER,
                                 x_org_id    NUMBER,
                                 x_item_name OUT NOCOPY VARCHAR2
                          ) IS

BEGIN
  x_item_name := NULL;
  IF wms_deployment_mode='L' then
     x_item_name := get_client_item(x_item_id,x_org_id);
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_item_name := NULL;
      IF (FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name, 'Get_Client_Info');
      END IF;
END Get_Client_Item_Name;


FUNCTION get_client_po_num (p_po_header_id  NUMBER)
RETURN VARCHAR2 AS
l_delimiter    VARCHAR2(1);
l_po_num    VARCHAR2(800);
BEGIN
    BEGIN
      SELECT segment1
      INTO   l_po_num
      FROM   po_headers_all
      WHERE  po_header_id = p_po_header_id;

    EXCEPTION
      WHEN OTHERS THEN
        l_po_num := NULL;
    END;
    IF wms_deployment_mode='L' THEN
      IF l_po_num       IS NOT NULL THEN
        l_delimiter := get_item_flex_delimiter;
        IF l_delimiter IS NOT NULL THEN
          l_po_num  := SUBSTR(l_po_num, 1, INSTR(l_po_num,l_delimiter,-1)-1);
        END IF;
      END IF;
    END IF;
    RETURN l_po_num;
END get_client_po_num;


procedure Get_Client_PONum_Info ( x_po_header_id     NUMBER,
                                  x_po_num OUT NOCOPY VARCHAR2
                          ) IS

BEGIN
  x_po_num := NULL;
  IF wms_deployment_mode='L' then
     x_po_num := get_client_po_num(x_po_header_id);
  ELSE SELECT segment1
       INTO x_po_num
       FROM po_headers_all
       WHERE po_header_id = x_po_header_id;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
    x_po_num := NULL;

      IF (FND_MSG_PUB.CHECK_MSG_LEVEL (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)) THEN
          FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name, 'Get_Client_Info');
      END IF;
END Get_Client_PONum_Info;
/* End of changes for LSP Integration project */

/*
**  Added function for bug 9274233
*/

FUNCTION get_po_number (p_segment1 VARCHAR2) RETURN NUMBER
IS
   l_delimiter VARCHAR2(1);
   l_client_code  mtl_client_parameters.client_code%TYPE;
   l_po_number NUMBER;
BEGIN
	IF wms_deployment_mode = 'L' THEN

    l_delimiter := wms_deploy.get_item_flex_delimiter;

    IF INSTR(p_segment1,l_delimiter) = 0 THEN

         l_po_number := to_number(p_segment1);

    ELSE

      l_client_code := SUBSTR(p_segment1, INSTR(p_segment1,l_delimiter,-1)+1);

      IF l_client_code IS NOT NULL THEN

          l_po_number := to_number(substr(p_segment1,1,instr(p_segment1,l_delimiter,-1)-1));

      ELSE

          l_po_number := to_number(p_segment1);

      END IF;
    END IF;

	ELSE
		l_po_number := to_number(p_segment1);
	END IF;

  RETURN l_po_number;
EXCEPTION
  WHEN INVALID_NUMBER THEN
        RETURN -1;
  WHEN OTHERS THEN
    IF SQLCODE = '-6502' THEN
        RETURN -1;
    END IF;
END get_po_number;

/*
**End of bug 9274233
*/

end WMS_DEPLOY;

/
