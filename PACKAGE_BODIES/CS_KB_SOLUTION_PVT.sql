--------------------------------------------------------
--  DDL for Package Body CS_KB_SOLUTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KB_SOLUTION_PVT" AS
/* $Header: cskvsolb.pls 120.2.12010000.3 2009/07/20 13:38:52 gasankar ship $ */
/*=======================================================================+
 |  Copyright (c) 2003 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME cskvsolb.pls
 | DESCRIPTION
 |   PL/SQL body for package:  CS_KB_SOLUTION_PVT
 |   This contains Private api's for a Solution
 |
 |   History:
 |   19 Aug 03 Matt Kettle   Created
 |   12 Sep 03 Matt Kettle   Changed Button Logic - If a solution is not
 |                           locked and not in a flow -return the checkout
 |                           button. Api changed: Get_User_Soln_Access
 |   25 Sep 03 Matt Kettle   Use message CS_KB_INV_SOLN_VIS for invalid
 |                           Solution Visibility in cre_sol and upd_sol
 |   13 Oct 03 Matt Kettle   Changed Submit_Solution to check for Dups
 |                           within the same solution
 |   25 Aug 04 Alan Wang     Add Move_Solution
 |   16 Mar 05 Matt Kettle   Changed Flag columns to use 'Y' and null
 |   22 Apr 05 Matt Kettle   BugFix 4013998 (FP of 3993200)-Sequence Id Fix
 |   17 May 05 Matt Kettle   Cleanup - removed obs apis (in 115.12):
 |                           Update_Element_Element
 |   19 Jul 05 Matt Kettle   Fix for 4464403 - Clone set and set eles
 |                           changed to take Source Set id. Removed
 |                           Get_Previous_Version_id
 |   20 Jul 07 ISUGAVAN      Bug fix 5947078(FP for Bug 5931800)
 |   12 Sep 08 mmaiya        Bugfix 7117546 - Unlock Locked Solutions in
 |			     Draft Mode
 |   06 May 09 mmaiya        12.1.3 Project: Search within attachments
 *=======================================================================*/

 PROCEDURE Get_Who(
   X_SYSDATE  OUT NOCOPY DATE,
   X_USER_ID  OUT NOCOPY NUMBER,
   X_LOGIN_ID OUT NOCOPY NUMBER )
 IS
 BEGIN

  X_SYSDATE := SYSDATE;
  X_USER_ID := FND_GLOBAL.user_id;
  X_LOGIN_ID := FND_GLOBAL.login_id;

 END Get_Who;

 PROCEDURE Get_Set_Details(
   P_SET_ID          IN          NUMBER,
   X_SET_NUMBER      OUT NOCOPY  VARCHAR2,
   X_STATUS          OUT NOCOPY  VARCHAR2,
   X_FLOW_DETAILS_ID OUT NOCOPY  NUMBER,
   X_LOCKED_BY       OUT NOCOPY  NUMBER )
 IS
 BEGIN

  SELECT set_number, status, flow_details_id, locked_by
    INTO X_SET_NUMBER, X_STATUS, X_FLOW_DETAILS_ID, X_LOCKED_BY
    FROM CS_KB_SETS_B
   WHERE set_id = p_set_id;

 END Get_Set_Details;



 FUNCTION Get_Set_Number(
   P_SET_ID IN NUMBER)
 RETURN VARCHAR2
 IS
  l_set_number VARCHAR2(30);
 BEGIN

  SELECT set_number
    INTO l_set_number
    FROM CS_KB_SETS_B
   WHERE set_id = p_set_id;

  RETURN l_set_number;

 END Get_Set_Number;

 -- BugFix 4013998 - Sequence Id Fix
 FUNCTION Get_Latest_Version_Id(
   P_SET_NUMBER IN VARCHAR2)
 RETURN NUMBER IS
  l_max_set_id NUMBER;

 CURSOR Get_Latest IS
  SELECT set_id
  FROM CS_KB_SETS_B
  WHERE set_number = p_set_number
  AND   latest_version_flag = 'Y';

 BEGIN

  OPEN  Get_Latest;
  FETCH Get_Latest INTO l_max_set_id;
  CLOSE Get_Latest;

  RETURN l_max_set_id;

 END Get_Latest_Version_Id;

 FUNCTION Get_Published_Set_Id(
   P_SET_NUMBER IN VARCHAR2)
 RETURN NUMBER IS

 l_count NUMBER;
 l_published_set_id NUMBER;

 BEGIN

  SELECT MAX(set_id)
  INTO l_published_set_id
  FROM CS_KB_SETS_B
  WHERE set_number = p_set_number
  AND status = 'PUB';

  IF (SQL%NOTFOUND) THEN RAISE NO_DATA_FOUND; END IF;

  RETURN l_published_set_id;

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN ERROR_STATUS;
 END Get_Published_Set_Id;


 FUNCTION Get_Obsoleted_Set_Id(
   P_SET_NUMBER IN VARCHAR2)
 RETURN NUMBER IS

 l_count NUMBER;
 l_obsoleted_set_id NUMBER;

 BEGIN

  SELECT MAX(set_id)
  INTO l_obsoleted_set_id
  FROM CS_KB_SETS_B
  WHERE set_number = p_set_number
  AND status = 'OBS';

  IF (SQL%NOTFOUND) THEN RAISE NO_DATA_FOUND; END IF;

  RETURN l_obsoleted_set_id;

 EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN ERROR_STATUS;
 END Get_Obsoleted_Set_Id;


 FUNCTION Get_Solution_Title(
   P_SET_ID IN NUMBER)
 RETURN VARCHAR2 IS
  l_solution_title CS_KB_SETS_TL.NAME%TYPE;
 BEGIN

  SELECT name
  INTO l_solution_title
  FROM CS_KB_SETS_TL
  WHERE set_id = p_set_id
  AND language = USERENV('LANG');

  RETURN l_solution_title;

 END Get_Solution_Title;


 PROCEDURE Get_Lock_Info(
   P_SET_NUMBER IN          VARCHAR2,
   X_LOCKED_BY  OUT NOCOPY  NUMBER,
   X_LOCK_DATE  OUT NOCOPY  DATE )
 IS
 BEGIN
  SELECT locked_by, lock_date
  INTO X_LOCKED_BY, X_LOCK_DATE
  FROM CS_KB_SETS_B
  WHERE set_id = Get_Latest_Version_Id(p_set_number);
 END Get_Lock_Info;

 PROCEDURE Set_Lock_Info(
   P_SET_ID    IN NUMBER,
   P_LOCKED_BY IN NUMBER,
   P_LOCK_DATE IN DATE )
 IS
 BEGIN

  UPDATE CS_KB_SETS_B
     SET locked_by = P_LOCKED_BY,
         lock_date = P_LOCK_DATE
  WHERE set_id = P_SET_ID;

 END Set_Lock_Info;


 FUNCTION Locked_By(
   p_set_number IN VARCHAR2)
 RETURN NUMBER
 IS
  l_locked_by NUMBER;
  l_lock_date DATE;
 BEGIN

  Get_Lock_Info(p_set_number, l_locked_by, l_lock_date);

  RETURN l_locked_by;

 END Locked_By;


 FUNCTION Locked_By(
   P_SET_ID IN NUMBER)
 RETURN NUMBER
 IS
  l_locked_by NUMBER;
 BEGIN

  SELECT locked_by
  INTO l_locked_by
  FROM CS_KB_SETS_B
  WHERE set_id = P_SET_ID;

  RETURN l_locked_by;

 END Locked_By;


 PROCEDURE Snatch_Lock_From_User(
   P_SET_ID     IN NUMBER,
   P_SET_NUMBER IN VARCHAR2,
   P_USER_ID    IN NUMBER,
   P_LOCKED_BY  IN NUMBER,
   X_RETURN_STATUS OUT NOCOPY  VARCHAR2,
   X_MSG_DATA      OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT     OUT NOCOPY  NUMBER) IS

  l_locked_by NUMBER;
  l_latest_set_id NUMBER;

 BEGIN

  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

  SELECT  locked_by
  INTO  l_locked_by
  FROM  CS_KB_SETS_B
  WHERE set_id = P_SET_ID FOR UPDATE;

  l_latest_set_id := Get_Latest_Version_Id(P_SET_NUMBER);

  -- check to see if the original user is still locking the solution
  -- and if there is no other new version for this solution

  IF ( (l_locked_by = P_LOCKED_BY) AND (l_latest_set_id = P_SET_ID) )
  THEN
    UPDATE CS_KB_SETS_B
    SET locked_by = P_USER_ID
    WHERE set_id = P_SET_ID;

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  ELSE
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_SOL_LOCKED_BY_USER');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
  END IF;


 EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data => x_msg_data);
 END Snatch_Lock_From_User;


 PROCEDURE Clear_Permissions(
   P_SET_NUMBER IN VARCHAR2)
 IS
 BEGIN

   UPDATE CS_KB_SETS_B
   SET    locked_by = NULL
   WHERE  set_number = p_set_number;

 EXCEPTION
   WHEN OTHERS THEN
        RAISE;
 END Clear_Permissions;


 PROCEDURE Update_Status(
   P_SET_ID IN NUMBER,
   P_STATUS IN VARCHAR2 )
 IS
  l_set_number VARCHAR2(30);
  l_access_level NUMBER;


 BEGIN

  UPDATE CS_KB_SETS_B
  SET    status = P_STATUS
  WHERE set_id = P_SET_ID;

 END Update_Status;


 PROCEDURE Update_Status(
   P_SET_NUMBER IN VARCHAR2,
   P_STATUS IN VARCHAR2 )
 IS
  l_max_set_id NUMBER;
  l_access_level NUMBER;

 BEGIN
  l_max_set_id := Get_Latest_Version_Id(p_set_number);

  Update_Status(p_set_id => l_max_set_id,
                p_status => p_status);

 END Update_Status;


 PROCEDURE Outdate_Solution(
   P_SET_NUMBER     IN VARCHAR2,
   P_CURRENT_SET_ID IN NUMBER )
 IS
 BEGIN
  UPDATE CS_KB_SETS_B
  SET    status = 'OUT',
         --viewable_version_flag = 'N'
         viewable_version_flag = null
  WHERE set_number = P_SET_NUMBER
  AND set_id <> P_CURRENT_SET_ID
  AND status = 'PUB';

 EXCEPTION
  WHEN OTHERS THEN
      RAISE;
 END Outdate_Solution;

 -- BugFix 4013998 - Sequence Id Fix
 FUNCTION Clone_Set(
   P_SET_NUMBER      IN VARCHAR2,
   P_ORIG_SET_ID     IN NUMBER,
   P_STATUS          IN VARCHAR2,
   P_FLOW_DETAILS_ID IN NUMBER,
   P_LOCKED_BY       IN NUMBER )
 RETURN NUMBER --set_id
 IS
  l_count PLS_INTEGER;
  l_old_set_id NUMBER;
  l_new_set_id NUMBER;
  l_SYSDATE  DATE;
  l_user_id  NUMBER;
  l_login_id NUMBER;
  b_rec CS_KB_SETS_B%ROWTYPE;
  l_dummy_rowid VARCHAR2(30);

  CURSOR get_tl_rows( v_set_id IN NUMBER) IS
   SELECT language,
          source_lang,
          name,
          description,
          composite_assoc_index,
	  composite_assoc_attach_index, --12.1.3
          positive_assoc_index,
          negative_assoc_index
   FROM CS_KB_SETS_TL
   WHERE Set_Id = v_set_id;

 BEGIN
  l_old_set_id := P_ORIG_SET_ID; --Get_Latest_Version_Id(p_set_number);

  SELECT * INTO b_rec
  FROM CS_KB_SETS_B
  WHERE set_id = l_old_set_id;

  Get_Who(l_SYSDATE, l_user_id, l_login_id);

  UPDATE CS_KB_SETS_B
  SET LATEST_VERSION_FLAG = null --'N'
  WHERE SET_NUMBER = b_rec.set_number
  AND   SET_ID = l_old_set_id;


  INSERT INTO CS_KB_SETS_B (
    set_id,
    set_number,
    set_type_id,
    status,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    locked_by,
    lock_date,
    attribute_category,
    attribute1,
    attribute2,
    attribute3,
    attribute4,
    attribute5,
    attribute6,
    attribute7,
    attribute8,
    attribute9,
    attribute10,
    attribute11,
    attribute12,
    attribute13,
    attribute14,
    attribute15,
    flow_details_id,
    priority_code,
    original_author,
    original_author_date,
    latest_version_flag,
    visibility_id,
    USAGE_SCORE,
    NORM_USAGE_SCORE
  ) VALUES (
    CS_KB_SETS_S.NEXTVAL,
    b_rec.set_number,
    b_rec.set_type_id,
    p_status,
    l_SYSDATE,
    l_user_id,
    l_SYSDATE,
    l_user_id,
    l_login_id,
    p_locked_by,
    l_SYSDATE,
    b_rec.attribute_category,
    b_rec.attribute1,
    b_rec.attribute2,
    b_rec.attribute3,
    b_rec.attribute4,
    b_rec.attribute5,
    b_rec.attribute6,
    b_rec.attribute7,
    b_rec.attribute8,
    b_rec.attribute9,
    b_rec.attribute10,
    b_rec.attribute11,
    b_rec.attribute12,
    b_rec.attribute13,
    b_rec.attribute14,
    b_rec.attribute15,
    p_flow_details_id,
    b_rec.priority_code,
    b_rec.original_author,
    b_rec.original_author_date,
    'Y',
    b_rec.visibility_id,
    b_rec.usage_score,
    b_rec.norm_usage_score
    )
    RETURNING SET_ID INTO l_new_set_id;

-- 17-Dec-2003 Perf change - Use DML Returning

  UPDATE CS_KB_SETS_B
  SET VIEWABLE_VERSION_FLAG = decode(status, 'PUB','Y',null)
  WHERE SET_NUMBER = b_rec.set_number;

  UPDATE CS_KB_SETS_B s
  SET s.VIEWABLE_VERSION_FLAG = 'Y'
  WHERE s.SET_NUMBER = b_rec.set_number
  AND   s.STATUS <> 'OBS'
  AND   s.LATEST_VERSION_FLAG = 'Y'
  AND NOT EXISTS (SELECT 'x'
                  FROM CS_KB_SETS_B s3
                  WHERE s3.set_number = s.set_number
                  AND   s3.STATUS = 'PUB');

 FOR tl_rec IN get_tl_rows(l_old_set_id) LOOP

      INSERT INTO CS_KB_SETS_TL (
        set_id,
        language,
        source_lang,
        name,
        description,
        composite_assoc_index,
	composite_assoc_attach_index, --12.1.3
        positive_assoc_index,
        negative_assoc_index,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login
      ) VALUES (
        l_new_set_id,
        tl_rec.language,
        tl_rec.source_lang,
        tl_rec.name,
        tl_rec.description,
        tl_rec.composite_assoc_index,
	tl_rec.composite_assoc_attach_index, --12.1.3
        tl_rec.positive_assoc_index,
        tl_rec.negative_assoc_index,
        l_SYSDATE,
        l_user_id,
        l_SYSDATE,
        l_user_id,
        l_login_id
      );
  END LOOP;

  RETURN l_new_set_id;

 END Clone_Set;



 FUNCTION Clone_Solution(
   P_SET_NUMBER      IN VARCHAR2,
   P_STATUS          IN VARCHAR2,
   P_FLOW_DETAILS_ID IN NUMBER,
   P_LOCKED_BY       IN NUMBER )
 RETURN NUMBER --set_id
 IS

  l_ret NUMBER;
  l_old_set_id NUMBER;
  l_new_set_id NUMBER;

  l_request_id number;
  l_return_status varchar2(1);
  l_asap_idx_enabled varchar2(4) := null;
  is_dup NUMBER;

  CURSOR GET_ELES_TO_UPDATE (p_set_id IN NUMBER) IS
   SELECT distinct element_id
   FROM CS_KB_SET_ELES
   WHERE set_id = p_set_id;

 --Added to resolve the bug 5947078
  CURSOR CHECK_STMT_ALREADY_ADDED (p_set_id IN NUMBER, p_ele_id IN NUMBER) IS
   SELECT count(*)
   FROM CS_KB_SET_ELES
   WHERE Set_id = p_set_id
   AND   Element_id = p_ele_id;

  l_check NUMBER;


 BEGIN

  -- Retrieve the Current Latest Version
  l_old_set_id := Get_Latest_Version_Id(P_SET_NUMBER);

  -- Set the locked_by to null for all Solution Versions
  Clear_Permissions(p_set_number => p_set_number);

  -- Clone the Solution
  -- Copy the exisiting Latest Version with the new status, lock and flow
  l_new_set_id := Clone_Set(
                     p_set_number,
                     l_old_set_id,
                     p_status,
                     p_flow_details_id,
                     p_locked_by
                     );

  -- Clone the Solution-Statement associations
  -- Copy the Statements from the old version to the new clone
  CS_KB_SET_ELES_PKG.Clone_Rows( P_SET_SOURCE_ID => l_old_set_id,
                                 P_SET_TARGET_ID => l_new_set_id);

  -- Clone the Solution External Links
  l_ret := CS_KB_SET_LINKS_PKG.Clone_Link
                     (p_set_source_id => l_old_set_id,
                      p_set_target_id => l_new_set_id);

  -- Clone any Products, Platforms and Categories associated to the Solution
  l_ret := CS_KB_ASSOC_PKG.Clone_Link
                     (p_set_source_id => l_old_set_id,
                      p_set_target_id => l_new_set_id);

  -- Clone any attatchments associated to the solution
  CS_KB_ATTACHMENTS_PKG.Clone_Attachment_Links(
                      p_set_source_id => l_old_set_id,
                      p_set_target_id => l_new_set_id);

  IF p_status = 'PUB' OR
     p_status = 'OBS' THEN

    -- Outdate previous Published Version ie set the old PUB row to status=OUT
    Outdate_Solution(p_set_number, l_new_set_id);

    IF (p_status = 'PUB') THEN

      -- If Solution is Published then Publish Statements
      -- Any Duplicate Statements will be obsoleted

      FOR eles IN GET_ELES_TO_UPDATE(l_new_set_id) LOOP

        is_dup := CS_KB_ELEMENTS_AUDIT_PKG.Is_Element_Created_Dup(eles.element_id);

        IF is_dup = 0 THEN
          UPDATE CS_KB_ELEMENTS_B
             SET status = 'PUBLISHED'
           WHERE element_id = eles.element_id;
        ELSE --element is duplicate so set to Obsolete
           UPDATE CS_KB_ELEMENTS_B
              SET status = 'OBS'
           WHERE element_id = eles.element_id;

	   -- Added to resolve the Bug 5947078
           OPEN  CHECK_STMT_ALREADY_ADDED ( l_new_set_id, is_dup);
           FETCH CHECK_STMT_ALREADY_ADDED INTO l_check;
           CLOSE CHECK_STMT_ALREADY_ADDED;

           IF l_check = 0 THEN

             UPDATE CS_KB_SET_ELES
             SET Element_id = is_dup
             WHERE set_id = l_new_set_id
             AND element_id = eles.element_id;

           ELSE

             DELETE FROM CS_KB_SET_ELES
             WHERE set_id = l_new_set_id
             AND element_id = eles.element_id;

           END IF;
	   --End of Change for Bug 5947078

        END IF;

      END LOOP;



      -- Logic For Auto Obsolete Statements Starts
      CS_KNOWLEDGE_AUDIT_PVT.Auto_Obsolete_For_Solution_Pub(p_set_number,
                                     Get_Published_Set_Id(p_set_number));

      -- Mark the new Published Solution Version for indexing
      CS_KB_SYNC_INDEX_PKG.Mark_Idxs_on_Pub_Soln( p_set_number );

      -- Populate the Solution Content cache
      CS_KB_SYNC_INDEX_PKG.Populate_Soln_Content_Cache (l_new_set_id);
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.cskvsolb.pls',
                         'Before Pop_Soln_Attach_Content_Cache - ');
        END IF;
      CS_KB_SYNC_INDEX_PKG.Pop_Soln_Attach_Content_Cache (l_new_set_id);
      IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
           FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'cs.plsql.cskvsolb.pls',
                         'After Pop_Soln_Attach_Content_Cache - ');
        END IF;

    ELSIF (p_status = 'OBS') THEN
      -- Logic For Auto Obsolete Statements Starts
      CS_KNOWLEDGE_AUDIT_PVT.Auto_Obsolete_For_Solution_Obs(p_set_number,
                                     Get_Obsoleted_Set_Id(p_set_number));

      -- Mark the new OBS Solution for indexing
      cs_kb_sync_index_pkg.Mark_Idxs_on_Obs_Soln( p_set_number );

    END IF;

    fnd_profile.get('CS_KB_ENABLE_ASAP_INDEXING', l_asap_idx_enabled);
    IF ( l_asap_idx_enabled = 'Y' )
    THEN
      CS_KB_SYNC_INDEX_PKG.request_sync_km_indexes( l_request_id, l_return_status );
    END IF;

  END IF;

  RETURN l_new_set_id;

 END Clone_Solution;


 FUNCTION Is_Status_Valid(
   P_STATUS IN VARCHAR2)
 RETURN VARCHAR2 IS
  l_count pls_integer;
 BEGIN

  SELECT COUNT(*) INTO l_count
    FROM cs_lookups
   WHERE lookup_type = 'CS_KB_INTERNAL_CODES'
     AND lookup_code = upper(p_status);
  IF(l_count<1) THEN
    RETURN fnd_api.g_false;
  ELSE
    RETURN fnd_api.g_true;
  END IF;

  RETURN fnd_api.g_true;

 END Is_Status_Valid;

-- Api's used in 11.5.10 by OAF:


 PROCEDURE Create_Solution(
   X_SET_ID             IN OUT NOCOPY NUMBER,
   P_SET_TYPE_ID        IN            NUMBER,
   P_NAME               IN            VARCHAR2,
   P_STATUS             IN            VARCHAR2,
   P_ATTRIBUTE_CATEGORY IN            VARCHAR2,
   P_ATTRIBUTE1         IN            VARCHAR2,
   P_ATTRIBUTE2         IN            VARCHAR2,
   P_ATTRIBUTE3         IN            VARCHAR2,
   P_ATTRIBUTE4         IN            VARCHAR2,
   P_ATTRIBUTE5         IN            VARCHAR2,
   P_ATTRIBUTE6         IN            VARCHAR2,
   P_ATTRIBUTE7         IN            VARCHAR2,
   P_ATTRIBUTE8         IN            VARCHAR2,
   P_ATTRIBUTE9         IN            VARCHAR2,
   P_ATTRIBUTE10        IN            VARCHAR2,
   P_ATTRIBUTE11        IN            VARCHAR2,
   P_ATTRIBUTE12        IN            VARCHAR2,
   P_ATTRIBUTE13        IN            VARCHAR2,
   P_ATTRIBUTE14        IN            VARCHAR2,
   P_ATTRIBUTE15        IN            VARCHAR2,
   X_SET_NUMBER         OUT NOCOPY    VARCHAR2,
   X_RETURN_STATUS      OUT NOCOPY    VARCHAR2,
   X_MSG_DATA           OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT          OUT NOCOPY    NUMBER,
   P_VISIBILITY_ID      IN            NUMBER )
 IS
  l_date  DATE;
  l_created_by NUMBER;
  l_login NUMBER;
  l_count PLS_INTEGER;
  l_rowid VARCHAR2(30);
  l_status VARCHAR2(30);
  l_set_id NUMBER;
  l_set_number VARCHAR2(30);
  l_ret_status VARCHAR2(1);
  l_msg   VARCHAR2(2000);
  l_dummy   VARCHAR2(1) := null;
  l_vis_count NUMBER;

  Cursor check_active_type_csr(p_type_id IN NUMBER) Is
    select 'X' from cs_kb_set_types_b
    where set_type_id = p_type_id
    and trunc(sysdate) between trunc(nvl(start_date_active, sysdate))
    and trunc(nvl(end_date_active, sysdate));

  Cursor Check_Visibility IS
  SELECT count(*)
  FROM CS_KB_VISIBILITIES_B
  WHERE Visibility_Id = p_visibility_id
  AND sysdate BETWEEN nvl(Start_Date_Active, sysdate-1)
                  AND nvl(End_Date_Active, sysdate+1);


 BEGIN
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

  -- Check Security
  OPEN  Check_Visibility;
  FETCH Check_Visibility INTO l_vis_count;
  CLOSE Check_Visibility;

  IF l_vis_count = 0 THEN
     FND_MSG_PUB.initialize;
     FND_MESSAGE.set_name('CS', 'CS_KB_INV_SOLN_VIS');
     FND_MSG_PUB.ADD;
     X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
     X_SET_ID   := -1;
     FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                               p_count   => X_MSG_COUNT,
                               p_data    => X_MSG_DATA);
  ELSE
    -- check params
    IF(p_set_type_id IS NULL OR p_name IS NULL) THEN
       FND_MSG_PUB.initialize;
       FND_MESSAGE.set_name('CS', 'CS_KB_C_MISS_PARAM');
       FND_MSG_PUB.ADD;
       X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
       X_SET_ID   := -1;
       FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                                 p_count   => X_MSG_COUNT,
                                 p_data    => X_MSG_DATA);

    ELSE
      -- IF type exists
      SELECT COUNT(*) INTO l_count
      FROM CS_KB_SET_TYPES_B
      WHERE set_type_id = p_set_type_id;

      IF(l_count <1) THEN
        FND_MSG_PUB.initialize;
        FND_MESSAGE.set_name('CS', 'CS_KB_C_INVALID_SET_TYPE_ID');
        FND_MSG_PUB.ADD;
        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
        X_SET_ID   := -2;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                                  p_count   => X_MSG_COUNT,
                                  p_data    => X_MSG_DATA);

      ELSE
        Open check_active_type_csr(p_set_type_id);
        Fetch check_active_type_csr Into l_dummy;
        Close check_active_type_csr;

        IF l_dummy Is Null Then
          FND_MSG_PUB.initialize;
          FND_MESSAGE.set_name('CS', 'CS_KB_EXPIRED_SOLUTION_TYPE');
          FND_MSG_PUB.ADD;
          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          X_SET_ID   := -4;
          FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                                    p_count   => X_MSG_COUNT,
                                    p_data    => X_MSG_DATA);
        ELSE
          --check status
          l_status := p_status;
          IF(l_status IS NULL) THEN
            l_status := 'SAV';
          END IF;
          --check unique set name IN audit table
          SELECT COUNT(*) INTO l_count
          FROM CS_KB_SETS_VL
          WHERE name = p_name
          AND status = 'PUB';

          IF(l_count >0) THEN
            FND_MSG_PUB.initialize;
            FND_MESSAGE.set_name('CS', 'CS_KB_C_DUP_SET_NAME');
            FND_MSG_PUB.ADD;
            X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
            X_SET_ID   := -3;
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                                      p_count   => X_MSG_COUNT,
                                      p_data    => X_MSG_DATA);
          ELSE

            IF x_set_id IS NULL THEN
              SELECT CS_KB_SETS_S.NEXTVAL INTO x_set_id FROM DUAL;
            END IF;

            SELECT TO_CHAR(CS_KB_SET_NUMBER_S.NEXTVAL) INTO x_set_number FROM DUAL;
            LOOP
              SELECT COUNT(set_number) INTO l_count
              FROM CS_KB_SETS_B
              WHERE set_number = x_set_number;
              EXIT WHEN l_count = 0;
              SELECT TO_CHAR(CS_KB_SET_NUMBER_S.NEXTVAL) INTO x_set_number FROM DUAL;
            END LOOP;

            IF x_set_id is NULL OR x_set_number is null THEN
              FND_MSG_PUB.initialize;
              FND_MESSAGE.set_name('CS', 'CS_KB_C_MISS_PARAM');
              FND_MSG_PUB.ADD;
              X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
              X_SET_ID  := -1;
              FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                                      p_count   => X_MSG_COUNT,
                                      p_data    => X_MSG_DATA);

            ELSE
              l_date := SYSDATE;
              l_created_by := FND_GLOBAL.user_id;
              l_login := FND_GLOBAL.login_id;

              CS_KB_SETS_PKG.Insert_Row( x_rowid => l_rowid,
                                         x_set_id => x_set_id,
                                         x_set_number => x_set_number,
                                         x_set_type_id => p_set_type_id,
                                         x_set_name => NULL,
                                         x_group_flag => NULL,
                                         x_status => l_status,
                                         x_access_level => null,
                                         x_name => p_name,
                                         x_description => null,
                                         x_creation_date => l_date,
                                         x_created_by => l_created_by,
                                         x_last_update_date => l_date,
                                         x_last_updated_by => l_created_by,
                                         x_last_update_login => l_login,
                                         x_locked_by => l_created_by,
                                         x_lock_date => NULL,
                                         x_attribute_category => p_attribute_category,
                                         x_attribute1 => p_attribute1,
                                         x_attribute2 => p_attribute2,
                                         x_attribute3 => p_attribute3,
                                         x_attribute4 => p_attribute4,
                                         x_attribute5 => p_attribute5,
                                         x_attribute6 => p_attribute6,
                                         x_attribute7 => p_attribute7,
                                         x_attribute8 => p_attribute8,
                                         x_attribute9 => p_attribute9,
                                         x_attribute10 => p_attribute10,
                                         x_attribute11 => p_attribute11,
                                         x_attribute12 => p_attribute12,
                                         x_attribute13 => p_attribute13,
                                         x_attribute14 => p_attribute14,
                                         x_attribute15 => p_attribute15,
                                         x_employee_id => NULL,
                                         x_party_id => NULL,
                                         x_start_active_date => NULL,
                                         x_end_active_date => NULL,
                                         x_priority_code => 4,
                                         x_visibility_id => p_visibility_id );

              X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

              UPDATE CS_KB_SETS_B
              SET LATEST_VERSION_FLAG = null --'N'
              WHERE SET_NUMBER = x_set_number
              AND   SET_ID <> x_set_id;

              UPDATE CS_KB_SETS_B
              SET VIEWABLE_VERSION_FLAG = decode(status, 'PUB','Y',null) --'N')
              WHERE SET_NUMBER = x_set_number;

              -- BugFix 4013998 - Sequence Id Fix
              UPDATE CS_KB_SETS_B s
              SET s.VIEWABLE_VERSION_FLAG = 'Y'
              WHERE s.SET_NUMBER = x_set_number
              AND   s.STATUS <> 'OBS'
              AND   s.latest_version_flag = 'Y'
              AND NOT EXISTS (SELECT 'x'
                              FROM CS_KB_SETS_B s3
                              WHERE s3.set_number = s.set_number
                              AND   s3.STATUS = 'PUB');

            END IF;

          END IF;

        END IF;

      END IF;

    END IF;

  END IF; -- Security Check

 EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data => x_msg_data);
 END Create_Solution;


 PROCEDURE Update_Solution(
   P_SET_ID             IN         NUMBER,
   P_SET_NUMBER         IN         VARCHAR2,
   P_SET_TYPE_ID        IN         NUMBER,
   P_NAME               IN         VARCHAR2,
   P_STATUS             IN         VARCHAR2,
   P_ATTRIBUTE_CATEGORY IN         VARCHAR2,
   P_ATTRIBUTE1         IN         VARCHAR2,
   P_ATTRIBUTE2         IN         VARCHAR2,
   P_ATTRIBUTE3         IN         VARCHAR2,
   P_ATTRIBUTE4         IN         VARCHAR2,
   P_ATTRIBUTE5         IN         VARCHAR2,
   P_ATTRIBUTE6         IN         VARCHAR2,
   P_ATTRIBUTE7         IN         VARCHAR2,
   P_ATTRIBUTE8         IN         VARCHAR2,
   P_ATTRIBUTE9         IN         VARCHAR2,
   p_attribute10        IN         VARCHAR2,
   P_ATTRIBUTE11        IN         VARCHAR2,
   P_ATTRIBUTE12        IN         VARCHAR2,
   P_ATTRIBUTE13        IN         VARCHAR2,
   P_ATTRIBUTE14        IN         VARCHAR2,
   P_ATTRIBUTE15        IN         VARCHAR2,
   X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
   X_MSG_DATA           OUT NOCOPY VARCHAR2,
   X_MSG_COUNT          OUT NOCOPY NUMBER,
   P_VISIBILITY_ID      IN         NUMBER )
 IS
  l_ret NUMBER;
  l_date  DATE;
  l_updated_by NUMBER;
  l_login NUMBER;
  l_count PLS_INTEGER;

  l_locked_by NUMBER;
  l_lock_date DATE;
  l_vis_count NUMBER;

  --SEDATE
  l_dummy     VARCHAR2(1) := null;
  Cursor check_active_type_csr(p_type_id IN NUMBER) Is
    select 'X' from cs_kb_set_types_b
    where set_type_id = p_type_id
    and trunc(sysdate) between trunc(nvl(start_date_active, sysdate))
    and trunc(nvl(end_date_active, sysdate));

  Cursor validate_old_type_used_csr(p_type_id IN NUMBER, p_set_id IN NUMBER) Is
    select 'x' from CS_KB_SETS_B
    where set_id = p_set_id
    and set_type_id = p_type_id;

  Cursor Check_Visibility IS
  SELECT count(*)
  FROM CS_KB_VISIBILITIES_B
  WHERE Visibility_Id = p_visibility_id
  AND sysdate BETWEEN nvl(Start_Date_Active, sysdate-1)
                  AND nvl(End_Date_Active, sysdate+1);

 BEGIN
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

  -- Check Security
  OPEN  Check_Visibility;
  FETCH Check_Visibility INTO l_vis_count;
  CLOSE Check_Visibility;

  IF l_vis_count = 0 THEN
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_SOLN_VIS');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                               p_count   => X_MSG_COUNT,
                               p_data    => X_MSG_DATA);
  ELSE
    -- validate params
    IF(p_set_number IS NULL OR p_set_id IS NULL OR p_set_type_id IS NULL ) THEN
      FND_MSG_PUB.initialize;
      FND_MESSAGE.set_name('CS', 'CS_KB_C_MISS_PARAM');
      FND_MSG_PUB.ADD;
      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                                p_count   => X_MSG_COUNT,
                                p_data    => X_MSG_DATA);
    ELSE

      SELECT COUNT(*) INTO l_count
      FROM CS_KB_SET_TYPES_B
      WHERE set_type_id = p_set_type_id;

      IF(l_count <1) THEN
        FND_MSG_PUB.initialize;
        FND_MESSAGE.set_name('CS', 'CS_KB_C_INVALID_SET_TYPE_ID');
        FND_MSG_PUB.ADD;
        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                                  p_count   => X_MSG_COUNT,
                                  p_data    => X_MSG_DATA);

      ELSE
        --SEDATE
        Open check_active_type_csr(p_set_type_id);
        Fetch check_active_type_csr Into l_dummy;
        Close check_active_type_csr;

        If l_dummy Is Null Then
          -- Check whether the p_set_type_id is same as the set_type_id in the solution.
          -- If yes, let it pass because it is a modification to a solution of which the expired
          -- solution type was active at the time when the solution was created.
          Open validate_old_type_used_csr(p_set_type_id, p_set_id);
          Fetch validate_old_type_used_csr Into l_dummy;
          Close validate_old_type_used_csr;
          If l_dummy Is Null Then
             FND_MSG_PUB.initialize;
             FND_MESSAGE.set_name('CS', 'CS_KB_END_DATED_TYPE');
             FND_MSG_PUB.ADD;
             X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                                       p_count   => X_MSG_COUNT,
                                       p_data    => X_MSG_DATA);
          End If;
        End If;

        IF l_dummy is not null THEN

          -- IF status valid
          IF(Is_Status_Valid(p_status) = FND_API.g_false) THEN
            FND_MSG_PUB.initialize;
            FND_MESSAGE.set_name('CS', 'CS_KB_C_INVALID_SET_STATUS');
            FND_MSG_PUB.ADD;
            X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                                      p_count   => X_MSG_COUNT,
                                      p_data    => X_MSG_DATA);
          ELSE

            --check unique set name IN audit table (except those with same set_number)
            SELECT COUNT(*) INTO l_count
            FROM CS_KB_SETS_VL
            WHERE name = p_name
            AND status = 'PUB'
            AND set_number <> p_set_number;

            IF(l_count >0) THEN
              FND_MSG_PUB.initialize;
              FND_MESSAGE.set_name('CS', 'CS_KB_C_DUP_SET_NAME');
              FND_MSG_PUB.ADD;
              X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
              FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                                        p_count   => X_MSG_COUNT,
                                        p_data    => X_MSG_DATA);
            ELSE

              --prepare data, THEN insert new set
              l_date := SYSDATE;
              l_updated_by := FND_GLOBAL.user_id;
              l_login := FND_GLOBAL.login_id;

              Get_Lock_Info(p_set_number, l_locked_by, l_lock_date);

              CS_KB_SETS_PKG.Update_Row(
                               x_set_id => p_set_id,
                               x_set_number => p_set_number,
                               x_set_type_id => p_set_type_id,
                               x_set_name => NULL,
                               x_group_flag => NULL,
                               x_status => p_status,
                               x_access_level => null,
                               x_name => p_name,
                               x_description => null,
                               x_last_update_date => l_date,
                               x_last_updated_by => l_updated_by,
                               x_last_update_login => l_login,
                               x_locked_by => l_locked_by,
                               x_lock_date => l_lock_date,
                               x_attribute_category => p_attribute_category,
                               x_attribute1 => p_attribute1,
                               x_attribute2 => p_attribute2,
                               x_attribute3 => p_attribute3,
                               x_attribute4 => p_attribute4,
                               x_attribute5 => p_attribute5,
                               x_attribute6 => p_attribute6,
                               x_attribute7 => p_attribute7,
                               x_attribute8 => p_attribute8,
                               x_attribute9 => p_attribute9,
                               x_attribute10 => p_attribute10,
                               x_attribute11 => p_attribute11,
                               x_attribute12 => p_attribute12,
                               x_attribute13 => p_attribute13,
                               x_attribute14 => p_attribute14,
                               x_attribute15 => p_attribute15,
                               x_employee_id => null,
                               x_party_id => null,
                               x_start_active_date => null,
                               x_end_active_date => null,
                               x_priority_code => 4,
                               x_visibility_id => p_visibility_id );

              X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

            END IF; -- check unique solution title (except those with same set_number)

          END IF; --valid status

        END IF; --valid type

      END IF; --valid set_type_id passed in

    END IF; --required params passed in

  END IF; -- Security Visibility Check

 EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UPDATE_ERR');
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
 END Update_Solution;


 -- Submit_Solution is an Internal api used to submit a solution. This api has the
 -- following steps:
 -- 1) Replace Duplicate Statements
 -- 2) Clone Solution
 -- 3) Send Notification via Oracle WorkFlow

 PROCEDURE Submit_Solution(
   P_SET_NUMBER  IN VARCHAR2,
   P_SET_ID      IN NUMBER ,
   P_NEW_STEP    IN NUMBER ,
   X_RETURN         OUT NOCOPY NUMBER,
   X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
   X_MSG_DATA       OUT NOCOPY VARCHAR2,
   X_MSG_COUNT      OUT NOCOPY NUMBER )
 IS

  CURSOR GET_STATEMENTS_FOR_DUP_CHECK(v_set_id IN NUMBER) IS
   SELECT se.element_id, e.element_number
   FROM CS_KB_SET_ELES se,
        CS_KB_ELEMENTS_B e
   WHERE se.set_id = v_set_id
   AND   se.element_id = e.element_id
   AND   e.status <> 'PUBLISHED';

  CURSOR Check_Dup_On_Current_Soln (v_set_id         IN NUMBER,
                                    v_dup_element_id IN NUMBER) IS
   SELECT count(*)
   FROM CS_KB_SET_ELES
   WHERE set_id = v_set_id
   AND element_id = v_dup_element_id;

  l_dup_element_id NUMBER;
  l_delete_status NUMBER;
  l_results NUMBER;
  l_errormsg VARCHAR2(2000);
--  test varchar2(10);
  l_dup_count NUMBER;

 BEGIN
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
  X_RETURN := -1;
  SAVEPOINT START_OF_SUBMIT;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'csk.plsql.CS_KB_SOLUTION_PVT.Submit_Solution.Start',
                   'Submit Solution started for set id- '||P_SET_ID );
  END IF;

  -- Firstly perform duplicate statement checking against exisiting
  -- Published statements. If duplicates exist
  -- then remove and replace set_ele link with original PUB statement

  FOR rec IN GET_STATEMENTS_FOR_DUP_CHECK(p_set_id) LOOP
    l_dup_element_id := CS_KB_ELEMENTS_AUDIT_PKG.Is_Element_Created_Dup(rec.element_id);

    IF l_dup_element_id <> 0 THEN

       -- Check if the Duplicate has already been added to the solution already
       OPEN  Check_Dup_On_Current_Soln (p_set_id, l_dup_element_id);
       FETCH Check_Dup_On_Current_Soln INTO l_dup_count;
       CLOSE Check_Dup_On_Current_Soln;
       IF l_dup_count = 0 THEN
         -- If Dup doesnt already exist
         UPDATE CS_KB_SET_ELES
         SET ELEMENT_ID = l_dup_element_id,
             LAST_UPDATE_DATE = sysdate,
             LAST_UPDATED_BY = FND_GLOBAL.user_id,
             LAST_UPDATE_LOGIN = FND_GLOBAL.login_id
         WHERE set_id = p_set_id
         AND element_id = rec.element_id;

         l_delete_status := CS_KB_ELEMENTS_AUDIT_PKG.Delete_Element(rec.element_number);
         -- No need to check delete status - if delete not valid ie statement shared then ignore
       ELSE
         -- If Dup does already exist
         DELETE FROM CS_KB_SET_ELES
         WHERE Set_Id = p_set_id
         AND element_id = rec.element_id;

       END IF;

    END IF;

  END LOOP;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'csk.plsql.CS_KB_SOLUTION_PVT.Submit_Solution',
                   'After Dup Check before Start_Wf - '||P_SET_ID );
  END IF;

  -- Start_Wf is an Internal api that performs the following:
  -- 1) Clone Solution
  -- 2) Send Notification via Oracle WorkFlow

  X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

  CS_KB_WF_PKG.Start_Wf( p_set_number  => p_set_number,
                         p_set_id      => p_set_id,
                         p_new_step    => p_new_step,
                         p_results     => l_results,
                         p_errormsg    => l_errormsg);

  IF l_results < 1 THEN
    ROLLBACK TO START_OF_SUBMIT;
    X_RETURN := -1; -- 'CS_KB_C_MISS_PARAM'
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_ERROR_WF_API');
    FND_MESSAGE.SET_TOKEN(TOKEN => 'ERROR_MSG',
                          VALUE => l_errormsg,
                          TRANSLATE => true);
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
  END IF;

  X_RETURN := l_results;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'csk.plsql.CS_KB_SOLUTION_PVT.Submit_Solution.Finish',
                   'Submit Solution finished for set id- '||P_SET_ID );
  END IF;

 EXCEPTION
  WHEN OTHERS THEN
   X_RETURN := -1;
   ROLLBACK TO START_OF_SUBMIT;

   IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'csk.plsql.CS_KB_SOLUTION_PVT.Submit_Solution.Unexpected',
                   'Unexpected Exception for set id- '||P_SET_ID||' '||substrb(sqlerrm,1,200) );
   END IF;

   FND_MSG_PUB.initialize;
   FND_MESSAGE.set_name('CS', 'CS_KB_C_ERROR_WF_API');
   FND_MESSAGE.SET_TOKEN(TOKEN => 'ERROR_MSG',
                         VALUE => SQLERRM,
                         TRANSLATE => true);
   FND_MSG_PUB.ADD;
   X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR;
   FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                             p_count   => X_MSG_COUNT,
                             p_data    => X_MSG_DATA);

 END Submit_Solution;

 -- BugFix 4013998 - Sequence Id Fix
 FUNCTION Get_User_Soln_Access (
   P_SET_ID     IN NUMBER,
   P_SET_NUMBER IN VARCHAR2 )
 RETURN VARCHAR2 IS

  -- Changed to use lvf, removed select max
  CURSOR Get_Latest_Soln_From_Id IS
   SELECT Set_Id
   FROM   CS_KB_SETS_B
   WHERE  Set_Number = (SELECT Set_Number
                        FROM   CS_KB_SETS_B
                        WHERE  Set_Id = P_SET_ID)
   AND    latest_version_flag = 'Y';

  -- Changed to use lvf, removed select max
  CURSOR Get_Latest_Soln_From_Num IS
   SELECT Set_Id
   FROM   CS_KB_SETS_B
   WHERE  Set_Number = P_SET_NUMBER
   AND    latest_version_flag = 'Y';

  CURSOR Get_Soln_Attributes (v_set_id NUMBER) IS
   SELECT Status, locked_by, flow_details_id
   FROM   CS_KB_SETS_B
   WHERE  Set_Id = v_set_id;

  l_default_user        NUMBER := -1;
  l_current_user        NUMBER := FND_GLOBAL.user_id;
  l_locked_by           NUMBER;
  l_flow_details_id     NUMBER;
  l_latest_set_id       NUMBER;
  l_status              VARCHAR2(30);
  Is_Full_Soln_Viewable VARCHAR2(10);
  l_result              NUMBER;
  l_button              VARCHAR2(15);
  l_set_id              NUMBER;

 BEGIN
  l_button := 'NOBUTTON';
  l_set_id := -1;
  l_latest_set_id := -2;

  -- Firstly Check the Set_Id for the Solution and determine if this is the
  -- latest version.
  IF P_SET_ID IS NOT NULL THEN

    l_set_id := P_SET_ID;

    OPEN  Get_Latest_Soln_From_Id;
    FETCH Get_Latest_Soln_From_Id INTO l_latest_set_id;
    CLOSE Get_Latest_Soln_From_Id;

  ELSIF P_SET_NUMBER IS NOT NULL AND P_SET_ID IS NULL THEN

    OPEN  Get_Latest_Soln_From_Num;
    FETCH Get_Latest_Soln_From_Num INTO l_latest_set_id;
    CLOSE Get_Latest_Soln_From_Num;
    l_set_id := l_latest_set_id;

  END IF;


  IF l_latest_set_id = l_set_id THEN
    -- The Current Set_Id is the Latest Version

    -- Now check the Status of the current version
    OPEN  Get_Soln_Attributes (l_set_id);
    FETCH Get_Soln_Attributes INTO l_status, l_locked_by, l_flow_details_id;
    CLOSE Get_Soln_Attributes;

    -- Now Check if the current User can view the Full Solution
    Is_Full_Soln_Viewable := CS_KB_SECURITY_PVT.IS_COMPLETE_SOLUTION_VISIBLE
                                                  ( l_default_user,
						    --l_current_user,
                                                    l_set_id);
    IF Is_Full_Soln_Viewable = 'TRUE' THEN
      -- Full Solution is Viewable


      IF l_status = 'PUB' THEN
        -- If the Latest is Published no need to check Resource Group
        -- as anyone can edit it

        l_button := 'CHECKOUT';

      ELSE
        -- Latest is Not Published or Solution is Locked

        CS_KB_WF_PKG.Get_Permissions(l_set_id, l_current_user, l_result);

        IF l_result = 2 THEN
          -- The Current User has the Solution Locked
          l_button := 'EDIT';
        ELSIF l_result = 1 THEN
          -- Solution is in a Workflow and is not locked
          -- The Current user is also able to Check Out the Solution
          l_button := 'CHECKOUT';
        ELSIF l_result = 0 THEN
          -- The Current User either does not have the lock or
          -- doesnt have permission to CheckOut the Solution

          IF l_locked_by <> l_current_user AND
             l_locked_by <> -1 THEN
            -- Solution is locked by another user
            l_button := 'GETLOCK';

            -- Note: The UI will check the presence of the GET_LOCK Function
            -- to determine whether the User has permission to see the Get Lock
            -- button.
          END IF;

          IF l_locked_by = -1 AND
             l_flow_details_id IS NULL THEN
             -- The Solution is not locked and is not currently in a flow
             -- This situation will occur when a draft solution is unlocked
             -- before it is submitted to a flow
             l_button := 'CHECKOUT';
          END IF;

        END IF;

      END IF;

    ELSE
      -- Full Solution is not Viewable
      IF l_locked_by = l_current_user THEN
        l_button := 'LOCKEDNOACCESS';
      ELSE
        l_button := 'NOBUTTON';
      END IF;


    END IF;


  ELSE
    -- This is not the latest version - Do Not show any Buttons
    l_button := 'NOBUTTON';
  END IF;

  RETURN l_button;

 EXCEPTION
  WHEN OTHERS THEN

    RETURN 'NOBUTTON';

 END Get_User_Soln_Access;

 PROCEDURE CheckOut_Solution(
   P_SET_ID         IN         NUMBER ,
   X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
   X_MSG_DATA       OUT NOCOPY VARCHAR2,
   X_MSG_COUNT      OUT NOCOPY NUMBER )
 IS

  CURSOR Get_Soln_Attributes (v_set_id NUMBER) IS
   SELECT Status, locked_by
   FROM   CS_KB_SETS_B
   WHERE  Set_Id = v_set_id;

  l_current_user  NUMBER := FND_GLOBAL.user_id;
  l_locked_by     NUMBER;
  l_set_number VARCHAR2(30);
  l_latest_set_id NUMBER;
  l_status    VARCHAR2(30);
  l_new_set_id NUMBER;

 BEGIN

  -- Check that the Solution Version is the latest
  l_set_number    := get_set_number(p_set_id);
  l_latest_set_id := get_latest_version_id(l_set_number);

  IF P_SET_ID = l_latest_set_id THEN

    -- Check the Solution Status
    OPEN  Get_Soln_Attributes (P_SET_ID);
    FETCH Get_Soln_Attributes INTO l_status, l_locked_by;
    CLOSE Get_Soln_Attributes;

    IF l_status = 'PUB' THEN
      -- If Current version is Published
      --> Clone Solution and assign current user to it
      l_new_set_id := clone_solution(l_set_number,
                                     'SAV',
                                     NULL,   --p_flow_details_id
                                     l_current_user);

      X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    ELSE
      -- If Not Published assign the lock to the current version for
      -- the current user

      IF (l_locked_by = -1) THEN
        -- Soln is unlocked so lock with current user
        Set_Lock_Info(p_set_id, l_current_user, sysdate);
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

      ELSIF (l_locked_by = l_current_user) THEN
         -- Current User already has the lock, ignore - do nothing
         X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
      ELSE
        -- Another user has locked the Solution
        -- return unsuccessful
        FND_MSG_PUB.initialize;
        FND_MESSAGE.set_name('CS', 'CS_KB_C_SOL_LOCKED_BY_USER');
        FND_MSG_PUB.ADD;
        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                                  p_count   => X_MSG_COUNT,
                                  p_data    => X_MSG_DATA);

      END IF;

    END IF;

  ELSE
    -- return unsuccessful
    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_CHECK_OUT_CHANGED');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
  END IF;
 EXCEPTION
  WHEN OTHERS THEN
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data => x_msg_data);
 END CheckOut_Solution;

 --Move given solutions from source category to destnation category.
 --If P_SRC_CAT_ID is -1, solutions will simply be added to the destination
 --category. Otherwise, the existing link to P_SRC_CAT_ID will be removed.
 --
 PROCEDURE Move_Solutions(
   p_api_version        in number,
   p_init_msg_list      in varchar2   := FND_API.G_FALSE,
   p_commit             in varchar2   := FND_API.G_FALSE,
   p_validation_level   in number     := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY varchar2,
   x_msg_count          OUT NOCOPY number,
   x_msg_data           OUT NOCOPY varchar2,
   P_SET_IDS        IN  JTF_NUMBER_TABLE,
   P_SRC_CAT_ID     IN  NUMBER,
   P_DEST_CAT_ID    IN  NUMBER)
 IS

  CURSOR Is_Linked (cp_set_id NUMBER) IS
   SELECT count(1)
   FROM   CS_KB_SET_CATEGORIES
   WHERE  Set_Id = cp_set_id
   AND    Category_Id = P_DEST_CAT_ID;

  CURSOR Is_Category_Existing (cp_cat_id NUMBER) IS
   SELECT count(1)
   FROM   CS_KB_SOLN_CATEGORIES_B
   WHERE  Category_Id = cp_cat_id;

  l_set_id NUMBER;
  l_cat_id NUMBER;
  l_count  NUMBER;

 BEGIN
    SAVEPOINT MOVE_SOLUTIONS;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'csk.plsql.CS_KB_SOLUTION_PVT.Move_Solutions.begin',
                   'User='||fnd_global.user_id);
    END IF;

    --Validate categories' id
    Open Is_Category_Existing(P_DEST_CAT_ID);
    Fetch Is_Category_Existing Into l_count;
    Close Is_Category_Existing;

    If l_count = 0 Then
        l_cat_id := P_DEST_CAT_ID;
        Raise INVALID_CATEGORY_ID;
    End If;

    If P_SRC_CAT_ID > 0 Then
        Open Is_Category_Existing(P_SRC_CAT_ID);
        Fetch Is_Category_Existing Into l_count;
        Close Is_Category_Existing;

        If l_count = 0 Then
            l_cat_id := P_SRC_CAT_ID;
            Raise INVALID_CATEGORY_ID;
        End If;
    End If;

    --Clear existing links and create new links
    for i in 1..p_set_ids.count loop
      l_set_id := p_set_ids(i);

      --Remove old link.
      If P_SRC_CAT_ID <> -1 Then
          delete from cs_kb_set_categories
          where set_id = l_set_id and category_id = P_SRC_CAT_ID;
          If SQL%notfound Then
              l_cat_id := P_SRC_CAT_ID;
              Raise INVALID_SET_CATEGORY_LINK;
          End If;
      End If;

      --Check if new link already existing.
      Open Is_Linked(l_set_id);
      Fetch Is_Linked Into l_count;
      Close Is_Linked;

      --If not linked create this link.
      if(l_count = 0) then
        insert into cs_kb_set_categories
        (
         set_id,
         category_id,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login
        )
        values
        (
         l_set_id,
         P_DEST_CAT_ID,
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id,
         fnd_global.login_id
        );
      end if;
    end loop;

    --Mark solution for index update.
    CS_KB_SYNC_INDEX_PKG.Mark_Idxs_For_Multi_Soln(P_SET_IDS);

    --Return.
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'csk.plsql.CS_KB_SOLUTION_PVT.Move_Solutions.begin',
                   'Status='||X_RETURN_STATUS);
    END IF;

    if fnd_api.to_boolean( p_commit ) then
	    commit;
    end if;

 EXCEPTION
  WHEN INVALID_CATEGORY_ID THEN
    ROLLBACK TO MOVE_SOLUTIONS;
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csk.plsql.CS_KB_SECURITY_PVT.Move_Solutions.validate_parameters',
                     'Invalid category ID:'||l_cat_id);
    END IF;

    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_API_SOLN_CAT_ID');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
  WHEN INVALID_SET_CATEGORY_LINK THEN
    ROLLBACK TO MOVE_SOLUTIONS;
    IF FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
       FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'csk.plsql.CS_KB_SECURITY_PVT.Move_Solutions.update_link',
                     'Invalid link (set_id,category_id): ('||l_set_id||','||l_cat_id||')');
    END IF;

    FND_MSG_PUB.initialize;
    FND_MESSAGE.set_name('CS', 'CS_KB_INV_SET_CAT_LINK');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
  WHEN OTHERS THEN
    ROLLBACK TO MOVE_SOLUTIONS;
    FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data => x_msg_data);
 END Move_Solutions;

  -- Unlock Locked Solutions in Draft Mode
 -- Start Bugfix 7117546
PROCEDURE unlock_solution
   (
      p_set_id IN NUMBER,
      p_commit IN VARCHAR2 DEFAULT 'N',
      x_return_status OUT NOCOPY VARCHAR2,
      x_msg_data      OUT NOCOPY VARCHAR2,
      x_msg_count     OUT NOCOPY NUMBER)
AS
   l_current_status VARCHAR2(3) ;
   l_pub_count NUMBER;
   l_set_number VARCHAR2(100) ;
BEGIN
   SAVEPOINT CS_KB_ULOCK_SOLUTION;

   SELECT set_number
   INTO   l_set_number
   FROM   cs_kb_sets_b
   WHERE  set_id = p_set_id;

   SELECT
      COUNT(*)
   INTO
      l_pub_count
   FROM
      cs_kb_sets_b
   WHERE
      status = 'PUB' AND
      set_number = l_set_number;

   IF l_pub_count > 0 THEN
      SELECT status INTO l_current_status FROM cs_kb_sets_b WHERE set_id = p_set_id;
      IF l_current_status = 'NOT' THEN
         UPDATE CS_KB_SETS_B SET locked_by = - 1 WHERE set_id = p_set_id;
      ELSIF l_current_status = 'SAV' THEN
         FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments(
                                                        x_entity_name => 'CS_KB_SETS_B',
                                                        x_pk1_value => TO_CHAR(p_set_id),
                                                        x_delete_document_flag => 'Y'
                                                        ) ;
         DELETE FROM CS_KB_SET_CATEGORIES WHERE set_id = p_set_id;
         DELETE FROM CS_KB_SET_PRODUCTS WHERE set_id = p_set_id;
         DELETE FROM CS_KB_SET_PLATFORMS WHERE set_id = p_set_id;
         DELETE FROM CS_KB_SET_LINKS WHERE set_id = p_set_id;
         DELETE FROM CS_KB_SET_ELES WHERE set_id = p_set_id;
         DELETE FROM CS_KB_SETS_TL WHERE set_id = p_set_id;
         UPDATE
            CS_KB_SETS_B
         SET
            latest_version_flag = 'Y'
         WHERE
            status = 'PUB' AND
            set_number = l_set_number;
         DELETE FROM CS_KB_SETS_B WHERE set_id = p_set_id;
      END IF;
      IF p_commit = 'Y' THEN
         COMMIT;
      END IF;
   END IF;
   x_return_status := 'S';
EXCEPTION
WHEN OTHERS THEN
   FND_MESSAGE.set_name('CS', 'CS_KB_C_UNEXP_ERR');
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data => x_msg_data);
   ROLLBACK TO CS_KB_ULOCK_SOLUTION;
END unlock_solution;
-- End Bugfix 7117546

END CS_KB_SOLUTION_PVT;

/
