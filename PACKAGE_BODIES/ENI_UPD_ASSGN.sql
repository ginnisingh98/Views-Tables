--------------------------------------------------------
--  DDL for Package Body ENI_UPD_ASSGN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_UPD_ASSGN" AS
/* $Header: ENIIASGB.pls 120.1 2005/10/18 03:22:49 lparihar noship $  */

  g_catset_id     NUMBER := ENI_DENORM_HRCHY.GET_CATEGORY_SET_ID;  -- Variable To Hold Product Catalog Category Set

PROCEDURE UPDATE_ASSGN_FLAG(
      p_new_category_id  IN NUMBER,
      p_old_category_id  IN NUMBER,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2) IS

  l_user_id          NUMBER := FND_GLOBAL.USER_ID; -- Bug# 3045649, user_id to be updated in last_updated_by column
  l_count            NUMBER;
  l_rows_updated     NUMBER; --Bug 4598106
BEGIN

  -- Updating Item Assignment flag to 'Y' for new_category_id
  -- Bug# 3045649, added WHO columns in update statements
  UPDATE ENI_DENORM_HIERARCHIES B
  SET ITEM_ASSGN_FLAG = 'Y',
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATED_BY = l_user_id,
      LAST_UPDATE_LOGIN = l_user_id
  WHERE OBJECT_TYPE = 'CATEGORY_SET'
    AND OBJECT_ID = g_catset_id
    AND ITEM_ASSGN_FLAG = 'N'
    AND CHILD_ID = NVL(p_new_category_id, -1);

  l_rows_updated := SQL%ROWCOUNT;

  -- Updating Item Assignment to 'N' for old_category_id, if there are no more items assigned to it
  -- Bug# 3045649, added WHO columns in update statements
  UPDATE ENI_DENORM_HIERARCHIES B
  SET ITEM_ASSGN_FLAG = 'N',
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATED_BY = l_user_id,
      LAST_UPDATE_LOGIN = l_user_id
  WHERE OBJECT_TYPE = 'CATEGORY_SET'
    AND OBJECT_ID = g_catset_id
    AND CHILD_ID = NVL(p_old_category_id, -1)
    AND ITEM_ASSGN_FLAG = 'Y'
    AND CHILD_ID <> -1
    AND NOT EXISTS (SELECT NULL
                    FROM MTL_ITEM_CATEGORIES C
                    WHERE C.CATEGORY_SET_ID = g_catset_id
                      AND C.CATEGORY_ID = B.CHILD_ID);

  l_rows_updated := l_rows_updated + SQL%ROWCOUNT;

/*Bug 4598106
  If no rows updated then the old_category and new category id are not
  product categories hence no need to execute further*/
  IF l_rows_updated = 0 then
     return;
  END IF;


  -- Checking Item assignment flag for Unassigned category
  -- if all items are attached to some categories within this category set then
  -- Item assignment flag for Unassigned node will be 'N'
  l_count := 0;

  BEGIN
  /**Bug 4675565 Replaced with the query below
    SELECT 1 INTO l_count
    FROM MTL_SYSTEM_ITEMS_B IT
    WHERE ROWNUM = 1
      AND NOT EXISTS (SELECT NULL FROM MTL_ITEM_CATEGORIES C
                      WHERE C.CATEGORY_SET_ID = g_catset_id
                        AND C.INVENTORY_ITEM_ID = IT.INVENTORY_ITEM_ID
                        AND C.ORGANIZATION_ID = IT.ORGANIZATION_ID);*/

    SELECT 1 INTO l_count
    FROM ENI_OLTP_ITEM_STAR star
    WHERE star.vbh_category_id = -1
      AND rownum = 1;

  EXCEPTION WHEN NO_DATA_FOUND THEN
    l_count := 0;
  END;

  UPDATE ENI_DENORM_HIERARCHIES B
  SET
    ITEM_ASSGN_FLAG = DECODE(l_count, 0, 'N', 'Y'),
    LAST_UPDATE_DATE = SYSDATE,
    LAST_UPDATED_BY = l_user_id,
    LAST_UPDATE_LOGIN = l_user_id
  WHERE B.OBJECT_TYPE = 'CATEGORY_SET'
    AND B.OBJECT_ID = g_catset_id
    AND B.ITEM_ASSGN_FLAG = DECODE(l_count, 0, 'Y', 'N')
    AND B.CHILD_ID = -1
    AND B.PARENT_ID = -1;

  x_return_status := 'S';
  x_msg_count := 0;
  x_msg_data := null;
EXCEPTION WHEN OTHERS THEN
  x_return_status := 'U';
  IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.ADD_EXC_MSG('ENI_UPD_ASSGN', 'UPDATE_ASSGN_FLAG', SQLERRM);
  END IF;
  FND_MSG_PUB.COUNT_AND_GET( P_COUNT => x_msg_count, P_DATA => x_msg_data);
END UPDATE_ASSGN_FLAG;

END ENI_UPD_ASSGN;

/
