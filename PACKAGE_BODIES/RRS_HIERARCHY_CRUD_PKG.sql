--------------------------------------------------------
--  DDL for Package Body RRS_HIERARCHY_CRUD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RRS_HIERARCHY_CRUD_PKG" AS
/* $Header: RRSHRCRB.pls 120.1.12010000.15 2010/03/03 01:58:28 pochang noship $ */
  G_PKG_NAME CONSTANT VARCHAR2(30) := 'RRS_HIERARCHY_CRUD_PKG';

procedure Update_Hierarchy_Header(
        p_api_version IN NUMBER DEFAULT 1,
        p_name IN VARCHAR2,
        p_new_name IN VARCHAR2 DEFAULT NULL,
        p_description IN VARCHAR2 DEFAULT NULL,
        p_purpose_code IN VARCHAR2 DEFAULT NULL,
        p_start_date IN DATE DEFAULT NULL,
        p_end_date IN DATE DEFAULT NULL,
        p_nullify_flag IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        x_return_status OUT NOCOPY varchar2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2
)IS

  v_hier_id NUMBER;
  v_root_id NUMBER;
  v_count NUMBER;
  v_meaning VARCHAR2(80);
	v_start_date DATE;
	v_end_date DATE;
BEGIN

  SAVEPOINT Update_Hierarchy_Header;

	IF p_nullify_flag <> FND_API.G_FALSE
		AND p_nullify_flag <> FND_API.G_TRUE THEN
		--RRS_INVALID_FLAG
    FND_MESSAGE.set_name('RRS', 'RRS_INVALID_FLAG');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
	END IF;

  BEGIN
    SELECT SITE_GROUP_ID
    INTO v_hier_id
    FROM RRS_SITE_GROUPS_VL
    WHERE NAME = p_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --RRS_NO_HIER_FOUND
      FND_MESSAGE.set_name('RRS', 'RRS_NO_HIER_FOUND');
      FND_MESSAGE.set_token('HIERARCHY_NAME', p_name);
      FND_MSG_PUB.add;
      --dbms_output.put_line('invalid hier name: '||p_name);
      RAISE FND_API.G_EXC_ERROR;
  END;

  --dbms_output.put_line(v_id);
  --dbms_output.put_line('valueof this:'||p_description);

  --dbms_output.put_line('purpose code: '||p_purpose_code);
  IF p_purpose_code IS NOT NULL THEN
    BEGIN
      SELECT MEANING
      INTO v_meaning
      FROM RRS_LOOKUPS_V
      WHERE LOOKUP_CODE = p_purpose_code
      AND LOOKUP_TYPE = 'RRS_HIERARCHY_PURPOSE'
			AND nvl(enabled_flag, 'Y') = 'Y'
      AND nvl(start_date_active, sysdate) <= sysdate
      AND nvl(end_date_active, sysdate) >= sysdate;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --RRS_NO_PURPOSE_FOUND
        FND_MESSAGE.set_name('RRS', 'RRS_NO_PURPOSE_FOUND');
        FND_MESSAGE.set_token('PURPOSE_CODE', p_purpose_code);
        FND_MSG_PUB.add;
        --dbms_output.put_line('invalid purpose: '||p_purpose_code);
        RAISE FND_API.G_EXC_ERROR;
    END;
  END IF;

  IF p_new_name IS NOT NULL THEN
    SELECT count(*)
    INTO v_count
    FROM RRS_SITE_GROUPS_TL
    WHERE NAME = p_new_name
    AND SITE_GROUP_ID <> v_hier_id;
    IF v_count <> 0 THEN
      --RRS_HIER_EXISTS
      FND_MESSAGE.set_name('RRS', 'RRS_HIER_EXISTS');
      FND_MESSAGE.set_token('HIERARCHY_NAME', p_new_name);
      FND_MSG_PUB.add;
      --dbms_output.put_line('invalid hier new name:'|| p_new_name);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  IF FND_API.To_Boolean(p_nullify_flag) AND p_new_name IS NULL THEN
    --RRS_NULL_NAME
    FND_MESSAGE.set_name('RRS', 'RRS_NULL_NAME');
    FND_MSG_PUB.add;
    --dbms_output.put_line('new name cannot be null');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

	--validate start/end date
	IF FND_API.To_Boolean(p_nullify_flag) THEN
		v_start_date := p_start_date;
		v_end_date := p_end_date;
	ELSE
		IF p_start_date IS NULL THEN
			SELECT START_DATE
			INTO v_start_date
			FROM RRS_SITE_GROUPS_B
			WHERE SITE_GROUP_ID = v_hier_id;
		ELSE
			v_start_date := p_start_date;
		END IF;
		IF p_end_date IS NULL THEN
			SELECT END_DATE
			INTO v_end_date
			FROM RRS_SITE_GROUPS_B
			WHERE SITE_GROUP_ID = v_hier_id;
		ELSE
			v_end_date := p_end_date;
		END IF;
	END IF;

	IF p_start_date IS NOT NULL
		AND p_start_date < sysdate THEN
		--RRS_START_DATE_PAST_ERR
		FND_MESSAGE.set_name('RRS', 'RRS_START_DATE_PAST_ERR');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
	ELSIF p_end_date IS NOT NULL
		AND p_end_date < sysdate THEN
		--RRS_END_DATE_PAST_ERR
		FND_MESSAGE.set_name('RRS', 'RRS_END_DATE_PAST_ERR');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
	ELSIF v_start_date IS NOT NULL
		AND v_end_date IS NOT NULL
		AND v_start_date > v_end_date THEN
		--RRS_INVALID_DATE_RANGE
		FND_MESSAGE.set_name('RRS', 'RRS_INVALID_DATE_RANGE');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
	END IF;

  --dbms_output.put_line('before update site group');

  UPDATE RRS_SITE_GROUPS_B RSGB
  SET RSGB.START_DATE = DECODE(p_nullify_flag, FND_API.G_TRUE, p_start_date, NVL(p_start_date, RSGB.START_DATE)),
      RSGB.END_DATE = DECODE(p_nullify_flag, FND_API.G_TRUE, p_end_date, NVL(p_end_date, RSGB.END_DATE)),
      RSGB.GROUP_PURPOSE_CODE = DECODE(p_nullify_flag, FND_API.G_TRUE, p_purpose_code, NVL(p_purpose_code, RSGB.GROUP_PURPOSE_CODE))
  WHERE RSGB.SITE_GROUP_ID = v_hier_id;

  UPDATE RRS_SITE_GROUPS_TL RSGT
  SET RSGT.DESCRIPTION = DECODE(p_nullify_flag, FND_API.G_TRUE, p_description, NVL(p_description, RSGT.DESCRIPTION)),
      RSGT.NAME = NVL(p_new_name, RSGT.NAME),
			RSGT.SOURCE_LANG = userenv('LANG')
  WHERE RSGT.SITE_GROUP_ID = v_hier_id
  AND RSGT.LANGUAGE = userenv('LANG');

  /*
  IF SQL%NOTFOUND THEN
    RAISE e_update_failed;
  END IF; */

  SELECT CHILD_MEMBER_ID
  INTO v_root_id
  FROM RRS_SITE_GROUP_MEMBERS
  WHERE SITE_GROUP_ID = v_hier_id
  AND PARENT_MEMBER_ID = -1;

  --dbms_output.put_line('before update node');

  UPDATE RRS_SITE_GROUP_NODES_TL RSGNT
  SET RSGNT.NAME = NVL(p_new_name, RSGNT.NAME),
			RSGNT.SOURCE_LANG = userenv('LANG')
  WHERE RSGNT.SITE_GROUP_NODE_ID = v_root_id
  AND RSGNT.LANGUAGE = userenv('LANG');

  /*IF SQL%NOTFOUND THEN
    RAISE e_update_failed;
  END IF;*/

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Update_Hierarchy_Header;
    x_msg_count := FND_MSG_PUB.Count_Msg;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    ROLLBACK TO Update_Hierarchy_Header;
    x_msg_data := G_PKG_NAME || '.Update_Hierarchy_Header:' || SQLERRM;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Update_Hierarchy_Header;

procedure Update_Hierarchy_Node(
        p_api_version IN NUMBER DEFAULT 1,
        p_number IN VARCHAR2,
        p_name IN VARCHAR2 DEFAULT NULL,
        p_description IN VARCHAR2 DEFAULT NULL,
        p_purpose_code IN VARCHAR2 DEFAULT NULL,
        p_nullify_flag IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        x_return_status OUT NOCOPY varchar2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2
) IS

  v_id NUMBER;
  v_meaning VARCHAR2(80);
  v_purpose_code VARCHAR2(30);
BEGIN

  SAVEPOINT Update_Hierarchy_Node;
  --dbms_output.put_line(p_number);

	IF p_nullify_flag <> FND_API.G_FALSE
		AND p_nullify_flag <> FND_API.G_TRUE THEN
		--RRS_INVALID_FLAG
    FND_MESSAGE.set_name('RRS', 'RRS_INVALID_FLAG');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
	END IF;

  BEGIN
    SELECT SITE_GROUP_NODE_ID, NODE_PURPOSE_CODE
    INTO v_id, v_purpose_code
    FROM RRS_SITE_GROUP_NODES_VL RSGNV
    WHERE RSGNV.NODE_IDENTIFICATION_NUMBER = p_number;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --RRS_NO_NODE_FOUND
      FND_MESSAGE.set_name('RRS', 'RRS_NO_NODE_FOUND');
      FND_MESSAGE.set_token('NODE_ID_NUM', p_number);
      FND_MSG_PUB.add;
      --dbms_output.put_line('no node found for:'||p_number);
      RAISE FND_API.G_EXC_ERROR;
  END;

  IF v_purpose_code = 'ROOT' THEN
    --RRS_TRANSACT_ROOT
    FND_MESSAGE.set_name('RRS', 'RRS_TRANSACT_ROOT');
    FND_MSG_PUB.add;
    --dbms_output.put_line('cannot transact a root node');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --dbms_output.put_line(v_id);

  IF p_purpose_code IS NOT NULL THEN
    BEGIN
      SELECT MEANING
      INTO v_meaning
      FROM RRS_LOOKUPS_V RLV
      WHERE RLV.LOOKUP_CODE = p_purpose_code
      AND  RLV.LOOKUP_TYPE = 'RRS_NODE_PURPOSE'
			AND nvl(enabled_flag, 'Y') = 'Y'
      AND nvl(start_date_active, sysdate) <= sysdate
      AND nvl(end_date_active, sysdate) >= sysdate;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --RRS_NO_PURPOSE_FOUND
        FND_MESSAGE.set_name('RRS', 'RRS_NO_PURPOSE_FOUND');
        FND_MESSAGE.set_token('PURPOSE_CODE', p_purpose_code);
        FND_MSG_PUB.add;
        --dbms_output.put_line('no purpose code found '||p_purpose_code);
        RAISE FND_API.G_EXC_ERROR;
    END;
  END IF;

  IF FND_API.To_Boolean(p_nullify_flag) AND p_name IS NULL THEN
    --RRS_NULL_NAME
    FND_MESSAGE.set_name('RRS', 'RRS_NULL_NAME');
    FND_MSG_PUB.add;
    --dbms_output.put_line('new name cannot be null');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  UPDATE RRS_SITE_GROUP_NODES_TL RSGNT
  SET RSGNT.DESCRIPTION = DECODE(p_nullify_flag, FND_API.G_TRUE, p_description, NVL(p_description, RSGNT.DESCRIPTION)),
      RSGNT.NAME = NVL(p_name, RSGNT.NAME),
			RSGNT.SOURCE_LANG = userenv('LANG')
  WHERE RSGNT.SITE_GROUP_NODE_ID = v_id
  AND RSGNT.LANGUAGE = userenv('LANG');

  /*
  IF SQL%NOTFOUND THEN
    RAISE e_update_failed;
  END IF; */

  UPDATE RRS_SITE_GROUP_NODES_B RSGNB
  SET RSGNB.NODE_PURPOSE_CODE = DECODE(p_nullify_flag, FND_API.G_TRUE, p_purpose_code, NVL(p_purpose_code, RSGNB.NODE_PURPOSE_CODE))
  WHERE RSGNB.SITE_GROUP_NODE_ID = v_id;

  /*
  IF SQL%NOTFOUND THEN
    RAISE e_update_failed;
  END IF; */

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Update_Hierarchy_Node;
    x_msg_count := FND_MSG_PUB.Count_Msg;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    ROLLBACK TO Update_Hierarchy_Node;
    x_msg_data := G_PKG_NAME || '.Update_Hierarchy_Node:' || SQLERRM;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Update_Hierarchy_Node;

procedure Create_Hierarchy_Node(
        p_api_version IN NUMBER DEFAULT 1,
        p_number IN VARCHAR2,
        p_name IN VARCHAR2 DEFAULT NULL,
        p_description IN VARCHAR2 DEFAULT NULL,
        p_purpose_code IN VARCHAR2 DEFAULT NULL,
        p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        x_return_status OUT NOCOPY varchar2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2
) IS

  v_id NUMBER;
  v_count NUMBER;
  v_meaning VARCHAR2(80);
BEGIN

  SAVEPOINT Create_Hierarchy_Node;

  IF p_number IS NULL THEN
    --RRS_ID_NUMBER_BOTH_NULL
    FND_MESSAGE.set_name('RRS', 'RRS_ID_NUMBER_BOTH_NULL');
    FND_MSG_PUB.add;
    --dbms_output.put_line('Id and number cannot both be NULL');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  SELECT count(*)
  INTO v_count
  FROM RRS_SITE_GROUP_NODES_VL RSGNV
  WHERE RSGNV.NODE_IDENTIFICATION_NUMBER = p_number;

  IF v_count <> 0 THEN
    --RRS_NODE_EXISTS
    FND_MESSAGE.set_name('RRS', 'RRS_NODE_EXISTS');
    FND_MESSAGE.set_token('NODE_ID_NUM', p_number);
    FND_MSG_PUB.add;
    --dbms_output.put_line('node already exists '||p_number);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_purpose_code IS NOT NULL THEN
    BEGIN
      SELECT MEANING
      INTO v_meaning
      FROM RRS_LOOKUPS_V RLV
      WHERE RLV.LOOKUP_CODE = p_purpose_code
      AND  RLV.LOOKUP_TYPE = 'RRS_NODE_PURPOSE'
			AND nvl(enabled_flag, 'Y') = 'Y'
      AND nvl(start_date_active, sysdate) <= sysdate
      AND nvl(end_date_active, sysdate) >= sysdate;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --RRS_NO_PURPOSE_FOUND
        FND_MESSAGE.set_name('RRS', 'RRS_NO_PURPOSE_FOUND');
        FND_MESSAGE.set_token('PURPOSE_CODE', p_purpose_code);
        FND_MSG_PUB.add;
        --dbms_output.put_line('invalid purpose '||p_purpose_code);
        RAISE FND_API.G_EXC_ERROR;
    END;
  END IF;

  --dbms_output.put_line(p_name);
  IF p_name IS NULL THEN
    --RRS_NULL_NAME
    FND_MESSAGE.set_name('RRS', 'RRS_NULL_NAME');
    FND_MSG_PUB.add;
    --dbms_output.put_line('null name');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

	SELECT RRS_SITES_S.NEXTVAL
	INTO v_id
	From dual;
  --v_id := RRS_SITES_S.NEXTVAL;
  --dbms_output.put_line(v_id);

  INSERT INTO RRS_SITE_GROUP_NODES_TL
	(
		SITE_GROUP_NODE_ID,
		LANGUAGE,
		SOURCE_LANG,
		NAME,
		DESCRIPTION,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN
	)
  SELECT v_id,
         L.LANGUAGE_CODE,
         userenv('LANG'),
         p_name,
         p_description,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id
	FROM FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG in ('I', 'B');

  /*
  IF SQL%NOTFOUND THEN
    RAISE e_insert_failed;
  END IF;*/

  --dbms_output.put_line(v_id || ' ' || p_purpose_code || ' ' || p_number);

  INSERT INTO RRS_SITE_GROUP_NODES_B
	(
		SITE_GROUP_NODE_ID,
		OBJECT_VERSION_NUMBER,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		NODE_PURPOSE_CODE,
		NODE_IDENTIFICATION_NUMBER
	)
  VALUES( v_id,
          1,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          p_purpose_code,
          p_number);

  /*
  IF SQL%NOTFOUND THEN
    RAISE e_insert_failed;
  END IF;*/

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --x_msg_count := FND_MSG_PUB.Count_Msg;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Hierarchy_Node;
    x_msg_count := FND_MSG_PUB.Count_Msg;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    ROLLBACK TO Create_Hierarchy_Node;
    x_msg_data := G_PKG_NAME || '.Create_Hierarchy_Node:' || SQLERRM;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Create_Hierarchy_Node;

procedure Create_Hierarchy_Coarse(
        p_api_version IN NUMBER DEFAULT 1,
        p_hier_name IN VARCHAR2,
        p_hier_description IN VARCHAR2 DEFAULT NULL,
        p_hier_purpose_code IN VARCHAR2 DEFAULT NULL,
        p_hier_start_date IN DATE DEFAULT NULL,
        p_hier_end_date IN DATE DEFAULT NULL,
        p_hier_members_tab IN RRS_HIER_MEMBERS_COARSE_TAB DEFAULT NULL,
        p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        x_return_status OUT NOCOPY varchar2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2
) IS

  v_count NUMBER;
  v_hier_id NUMBER;
  v_root_id NUMBER;
  v_hier_version_id NUMBER;
  v_meaning VARCHAR2(80);
BEGIN

  SAVEPOINT Create_Hierarchy_Coarse;

  --check if the hier name is null
  IF p_hier_name IS NULL THEN
    --RRS_NULL_NAME
    FND_MESSAGE.set_name('RRS', 'RRS_NULL_NAME');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --check if the hierarchy already exists
  SELECT COUNT(*)
  INTO v_count
  FROM RRS_SITE_GROUPS_TL
  WHERE NAME = p_hier_name;

  IF v_count <> 0 THEN
    --RRS_HIER_EXISTS
    FND_MESSAGE.set_name('RRS', 'RRS_HIER_EXISTS');
    FND_MESSAGE.set_token('HIERARCHY_NAME', p_hier_name);
    FND_MSG_PUB.add;
    --dbms_output.put_line('hier name already exists');
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  --validate the hierarchy purpose code
  IF p_hier_purpose_code IS NOT NULL THEN
    BEGIN
      SELECT MEANING
      INTO v_meaning
      FROM RRS_LOOKUPS_V RLV
      WHERE RLV.LOOKUP_CODE = p_hier_purpose_code
      AND  RLV.LOOKUP_TYPE = 'RRS_HIERARCHY_PURPOSE'
			AND nvl(enabled_flag, 'Y') = 'Y'
      AND nvl(start_date_active, sysdate) <= sysdate
      AND nvl(end_date_active, sysdate) >= sysdate;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --RRS_NO_PURPOSE_FOUND
        FND_MESSAGE.set_name('RRS', 'RRS_NO_PURPOSE_FOUND');
        FND_MESSAGE.set_token('PURPOSE_CODE', p_hier_purpose_code);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
    END;
  END IF;

	--validate start/end date
	IF p_hier_start_date IS NOT NULL
		AND p_hier_start_date < sysdate THEN
		--RRS_START_DATE_PAST_ERR
		FND_MESSAGE.set_name('RRS', 'RRS_START_DATE_PAST_ERR');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
	ELSIF p_hier_end_date IS NOT NULL
		AND p_hier_end_date < sysdate THEN
		--RRS_END_DATE_PAST_ERR
		FND_MESSAGE.set_name('RRS', 'RRS_END_DATE_PAST_ERR');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
	ELSIF p_hier_start_date IS NOT NULL
		AND p_hier_end_date IS NOT NULL
		AND p_hier_start_date > p_hier_end_date THEN
		--RRS_INVALID_DATE_RANGE
		FND_MESSAGE.set_name('RRS', 'RRS_INVALID_DATE_RANGE');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
	END IF;

  --retrieve new site group id from the sequence
  SELECT RRS_SITE_GROUPS_S.NEXTVAL
	INTO v_hier_id
	From dual;
	--v_hier_id := RRS_SITE_GROUPS_S.NEXTVAL;
  --dbms_output.put_line('hier_id: '||v_hier_id);
  --insert new row into RRS_SITE_GROUPS_TL table
  INSERT INTO RRS_SITE_GROUPS_TL
	(
		SITE_GROUP_ID,
		LANGUAGE,
		SOURCE_LANG,
		NAME,
		DESCRIPTION,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN
	)
  SELECT v_hier_id,
          L.LANGUAGE_CODE,
          userenv('LANG'),
          p_hier_name,
          p_hier_description,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id
	FROM FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG in ('I', 'B');

  /*
  IF SQL%NOTFOUND THEN
    RAISE e_insert_failed;
  END IF;*/

  --insert new row into RRS_SITE_GROUPS_B table
  INSERT INTO RRS_SITE_GROUPS_B
	(
		SITE_GROUP_ID,
		SITE_GROUP_TYPE_CODE,
		START_DATE,
		END_DATE,
		OBJECT_VERSION_NUMBER,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		GROUP_PURPOSE_CODE
	)
  VALUES( v_hier_id,
          'H',
          p_hier_start_date,
          p_hier_end_date,
          1,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          p_hier_purpose_code);
  /*
  IF SQL%NOTFOUND THEN
    RAISE e_insert_failed;
  END IF;*/

  --retrieve new version id from the sequence
	SELECT RRS_SITE_GROUP_VERSIONS_S.NEXTVAL
	INTO v_hier_version_id
	From dual;
  --v_hier_version_id := RRS_SITE_GROUP_VERSIONS_S.NEXTVAL;
  --dbms_output.put_line(v_hier_version_id);
  --insert new row into RRS_SITE_GROUP_VERSIONS table
  INSERT INTO RRS_SITE_GROUP_VERSIONS
	(
		SITE_GROUP_VERSION_ID,
		SITE_GROUP_ID,
		VERSION_NUMBER,
		SOURCE_VERSION_ID,
		OBJECT_VERSION_NUMBER,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN
	)
  VALUES( v_hier_version_id,
          v_hier_id,
          1,
          v_hier_version_id,
          1,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id);

  /*
  IF SQL%NOTFOUND THEN
    RAISE e_insert_failed;
  END IF;*/

  --creat new root node
  --retrieve new node id from the sequence
	SELECT RRS_SITES_S.NEXTVAL
	INTO v_root_id
	From dual;
  --v_root_id := RRS_SITES_S.NEXTVAL;
  --insert new row into RRS_SITE_GROUP_NODES_TL table
  INSERT INTO RRS_SITE_GROUP_NODES_TL
	(
		SITE_GROUP_NODE_ID,
		LANGUAGE,
		SOURCE_LANG,
		NAME,
		DESCRIPTION,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN
	)
  SELECT v_root_id,
          L.LANGUAGE_CODE,
          userenv('LANG'),
          p_hier_name,
          NULL,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id
	FROM FND_LANGUAGES L
  WHERE L.INSTALLED_FLAG in ('I', 'B');
  /*
  IF SQL%NOTFOUND THEN
    RAISE e_insert_failed;
  END IF;*/

  --insert new row into RRS_SITE_GROUP_NODES_B table
  INSERT INTO RRS_SITE_GROUP_NODES_B
	(
		SITE_GROUP_NODE_ID,
		OBJECT_VERSION_NUMBER,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		NODE_PURPOSE_CODE,
		NODE_IDENTIFICATION_NUMBER
	)
  VALUES( v_root_id,
          1,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          'ROOT',
          v_root_id);
  /*
  IF SQL%NOTFOUND THEN
    RAISE e_insert_failed;
  END IF;*/

  Create_Hierarchy_Members(
        p_hier_version_id => v_hier_version_id,
        p_hier_id => v_hier_id,
        p_root_id => v_root_id,
        p_root_number => null,
        p_hier_purpose_code => p_hier_purpose_code,
        p_hier_members_tab => p_hier_members_tab,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Hierarchy_Coarse;
    x_msg_count := FND_MSG_PUB.Count_Msg;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_Hierarchy_Coarse;
    x_msg_data := G_PKG_NAME || '.Create_Hierarchy_Coarse:' || x_msg_data;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    ROLLBACK TO Create_Hierarchy_Coarse;
    x_msg_data := G_PKG_NAME || '.Create_Hierarchy_Coarse:' || SQLERRM;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Create_Hierarchy_Coarse;

procedure Validate_Rules_For_Members(
        p_hier_purpose_code IN VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_data OUT NOCOPY VARCHAR2
)IS
  CURSOR validate_rules_cursor IS
  SELECT PARENT_TYPE, PARENT_NUMBER, CHILD_TYPE, CHILD_NUMBER
  FROM RRS_SITE_GROUP_MEMBERS_TEMP
  WHERE CHILD_ID NOT IN (
    SELECT CHILD_ID
    FROM RRS_SITE_GROUP_MEMBERS_TEMP RSGMT, RRS_GROUP_RULES RGR
    WHERE RGR.SITE_GROUP_TYPE_CODE = 'H'
    AND RGR.GROUP_PURPOSE_CODE = p_hier_purpose_code
    AND RGR.RELATIONSHIP_TYPE = 'PARENT_CHILD'
    AND RSGMT.PARENT_TYPE = RGR.OBJECT1
    AND RSGMT.PARENT_PURPOSE_CODE = RGR.CLASSIFICATION_CODE1
    AND RSGMT.CHILD_TYPE = RGR.OBJECT2
    AND RSGMT.CHILD_PURPOSE_CODE = RGR.CLASSIFICATION_CODE2);

  v_count NUMBER;
  v_p_num VARCHAR2(30);
  v_p_type VARCHAR2(30);
  v_c_num VARCHAR2(30);
  v_c_type VARCHAR2(30);

BEGIN
  --initialize the return status
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --dbms_output.put_line('before RulesFwk');
  SELECT COUNT(*)
  INTO v_count
  FROM (
    SELECT *
    FROM RRS_GROUP_RULES RGR
    WHERE RGR.GROUP_PURPOSE_CODE = p_hier_purpose_code) TMP;

  IF v_count <> 0 THEN

    OPEN validate_rules_cursor;
    LOOP
      FETCH validate_rules_cursor INTO v_p_type, v_p_num, v_c_type, v_c_num;
      EXIT WHEN validate_rules_cursor%NOTFOUND OR validate_rules_cursor%NOTFOUND IS NULL;
      --RRS_NO_RULE_FOUND
      FND_MESSAGE.set_name('RRS', 'RRS_NO_RULE_FOUND');
      FND_MESSAGE.set_token('P_TYPE', v_p_type);
      FND_MESSAGE.set_token('P_NUM', v_p_num);
      FND_MESSAGE.set_token('C_TYPE', v_c_type);
      FND_MESSAGE.set_token('C_NUM', v_c_num);
      FND_MSG_PUB.add;
      --dbms_output.put_line('The following member violates the RulesFwk: '||v_p_type||'/'||v_p_num||'/'||v_c_type||'/'||v_c_num);
      x_return_status := FND_API.G_RET_STS_ERROR;
    END LOOP;
    CLOSE validate_rules_cursor;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_msg_data := G_PKG_NAME || '.Validate_Rules_For_Members:' || SQLERRM;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Rules_For_Members;

procedure Validate_Rules_For_Child(
        p_hier_purpose_code IN VARCHAR2,
        p_parent_id_number IN VARCHAR2,
        p_parent_object_type IN VARCHAR2,
        p_parent_purpose_code IN VARCHAR2,
        p_child_id_number IN VARCHAR2,
        p_child_object_type IN VARCHAR2,
        p_child_purpose_code IN VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_data OUT NOCOPY VARCHAR2
)IS

  v_count NUMBER;

BEGIN

  --dbms_output.put_line('before RulesFwk');
  SELECT COUNT(*)
  INTO v_count
  FROM (
    SELECT *
    FROM RRS_GROUP_RULES RGR
    WHERE RGR.GROUP_PURPOSE_CODE = p_hier_purpose_code) TMP;
  IF v_count <> 0 THEN
    SELECT COUNT(*)
    INTO v_count
    FROM RRS_GROUP_RULES RGR
    WHERE RGR.SITE_GROUP_TYPE_CODE = 'H'
    AND RGR.GROUP_PURPOSE_CODE = p_hier_purpose_code
    AND RGR.RELATIONSHIP_TYPE = 'PARENT_CHILD'
    AND RGR.OBJECT1 = p_parent_object_type
    AND RGR.CLASSIFICATION_CODE1 = p_parent_purpose_code
    AND RGR.OBJECT2 = p_child_object_type
    AND RGR.CLASSIFICATION_CODE2 = p_child_purpose_code;
    IF v_count = 0 THEN
      --RRS_NO_RULE_FOUND
      FND_MESSAGE.set_name('RRS', 'RRS_NO_RULE_FOUND');
      FND_MESSAGE.set_token('P_TYPE', p_parent_object_type);
      FND_MESSAGE.set_token('P_NUM', p_parent_id_number);
      FND_MESSAGE.set_token('C_TYPE', p_child_object_type);
      FND_MESSAGE.set_token('C_NUM', p_child_id_number);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Rules validation failed');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    x_msg_data := G_PKG_NAME || '.Validate_Rules_For_Child:' || SQLERRM;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Rules_For_Child;

procedure Create_Hierarchy_Members(
        p_hier_version_id IN NUMBER,
        p_hier_id IN NUMBER,
        p_root_id IN NUMBER,
        p_root_number IN VARCHAR2,
        p_hier_purpose_code IN VARCHAR2,
        p_hier_members_tab IN RRS_HIER_MEMBERS_COARSE_TAB,
        x_return_status OUT NOCOPY varchar2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2
)IS

	v_count NUMBER;
  v_root_id NUMBER;
  v_root_number VARCHAR(30);
  v_node_name VARCHAR2(150);
  v_node_description VARCHAR(2000);
  v_meaning VARCHAR2(80);
  v_purpose_code VARCHAR2(30);
  v_id NUMBER;
  v_num VARCHAR2(30);
  v_type VARCHAR2(30);
  v_p_num VARCHAR2(30);
  v_p_type VARCHAR2(30);
  v_c_num VARCHAR2(30);
  v_c_type VARCHAR2(30);

  CURSOR new_nodes_cursor IS
  SELECT *
  FROM RRS_SITE_GROUP_MEMBERS_TEMP
  WHERE CHILD_TYPE = 'NODE'
  AND CHILD_ID IS NULL
  AND CHILD_NUMBER IS NOT NULL
  AND CHILD_NUMBER NOT IN (
    SELECT NODE_IDENTIFICATION_NUMBER
    FROM RRS_SITE_GROUP_NODES_VL
    WHERE NODE_IDENTIFICATION_NUMBER IS NOT NULL);

  CURSOR update_nodes_cursor IS
  SELECT *
  FROM RRS_SITE_GROUP_MEMBERS_TEMP
  WHERE CHILD_TYPE = 'NODE'
  AND CHILD_NUMBER IS NOT NULL
  AND (CHILD_PURPOSE_CODE IS NOT NULL
    OR CHILD_NODE_NAME IS NOT NULL
    OR CHILD_NODE_DESCRIPTION IS NOT NULL);

  CURSOR new_members_cursor IS
  SELECT *
  FROM RRS_SITE_GROUP_MEMBERS_TEMP;

  CURSOR validate_p_id_num_cursor IS
  SELECT PARENT_ID, PARENT_NUMBER
  FROM RRS_SITE_GROUP_MEMBERS_TEMP
  WHERE (PARENT_ID IS NOT NULL AND PARENT_NUMBER IS NOT NULL)
    AND ((PARENT_ID, PARENT_NUMBER) NOT IN (SELECT SITE_ID, SITE_IDENTIFICATION_NUMBER FROM RRS_SITES_VL)
      AND (PARENT_ID, PARENT_NUMBER) NOT IN (SELECT SITE_GROUP_NODE_ID, NODE_IDENTIFICATION_NUMBER FROM RRS_SITE_GROUP_NODES_VL));

  CURSOR validate_c_id_num_cursor IS
  SELECT CHILD_ID, CHILD_NUMBER
  FROM RRS_SITE_GROUP_MEMBERS_TEMP
  WHERE (CHILD_ID IS NOT NULL AND CHILD_NUMBER IS NOT NULL)
    AND ((CHILD_ID, CHILD_NUMBER) NOT IN (SELECT SITE_ID, SITE_IDENTIFICATION_NUMBER FROM RRS_SITES_VL)
      AND (CHILD_ID, CHILD_NUMBER) NOT IN (SELECT SITE_GROUP_NODE_ID, NODE_IDENTIFICATION_NUMBER FROM RRS_SITE_GROUP_NODES_VL));

  CURSOR validate_p_id_cursor IS
  SELECT PARENT_TYPE, PARENT_ID, PARENT_NUMBER
  FROM RRS_SITE_GROUP_MEMBERS_TEMP RSGMT
  WHERE PARENT_ID IS NOT NULL
    AND ((PARENT_TYPE = 'SITE'
      AND NOT EXISTS (
        SELECT SITE_ID
        FROM RRS_SITES_B
  	    WHERE SITE_ID = RSGMT.PARENT_ID))
    OR (PARENT_TYPE = 'NODE'
    AND NOT EXISTS (
        SELECT SITE_GROUP_NODE_ID
        FROM RRS_SITE_GROUP_NODES_B
	    WHERE SITE_GROUP_NODE_ID = RSGMT.PARENT_ID)));

  CURSOR validate_c_id_cursor IS
  SELECT CHILD_TYPE, CHILD_ID, CHILD_NUMBER
  FROM RRS_SITE_GROUP_MEMBERS_TEMP RSGMT
  WHERE CHILD_ID IS NOT NULL
    AND ((CHILD_TYPE = 'SITE'
      AND NOT EXISTS (
        SELECT SITE_ID
        FROM RRS_SITES_B
	    WHERE SITE_ID = RSGMT.CHILD_ID))
    OR (CHILD_TYPE = 'NODE'
      AND NOT EXISTS (
        SELECT SITE_GROUP_NODE_ID
        FROM RRS_SITE_GROUP_NODES_B
	    WHERE SITE_GROUP_NODE_ID = RSGMT.CHILD_ID)));

  CURSOR validate_dup_number_cursor IS
  SELECT CHILD_TYPE, CHILD_NUMBER
  FROM RRS_SITE_GROUP_MEMBERS_TEMP
  GROUP BY CHILD_TYPE, CHILD_NUMBER
  HAVING COUNT(*) > 1;

  CURSOR validate_num_cursor IS
  SELECT DECODE(PARENT_ID, NULL, PARENT_NUMBER, CHILD_NUMBER), DECODE(PARENT_ID, NULL, PARENT_TYPE, CHILD_TYPE)
  FROM RRS_SITE_GROUP_MEMBERS_TEMP
  WHERE CHILD_ID IS NULL
  OR PARENT_ID IS NULL;

  CURSOR validate_site_template_cursor IS
  SELECT CHILD_NUMBER
  FROM RRS_SITE_GROUP_MEMBERS_TEMP RSGMT, RRS_SITES_VL RSV
  WHERE RSGMT.CHILD_ID = RSV.SITE_ID
  AND RSGMT.CHILD_TYPE = 'SITE'
  AND IS_TEMPLATE_FLAG = 'Y';

  CURSOR validate_node_name_cursor IS
  SELECT RSGNV.NAME
  FROM RRS_SITE_GROUP_MEMBERS_TEMP RSGMT, RRS_SITE_GROUP_NODES_VL RSGNV
  WHERE RSGMT.CHILD_ID = RSGNV.SITE_GROUP_NODE_ID
  GROUP BY RSGMT.PARENT_ID, RSGNV.NAME
  HAVING COUNT(*) > 1;

  CURSOR validate_p_in_hier_curosr IS
  SELECT RSGMT.CHILD_TYPE, RSGMT.CHILD_NUMBER
  FROM RRS_SITE_GROUP_MEMBERS_TEMP RSGMT
  WHERE RSGMT.PARENT_ID <> p_root_id
  AND (RSGMT.PARENT_TYPE, RSGMT.PARENT_NUMBER) NOT IN
    (SELECT RSGMT2.CHILD_TYPE, RSGMT2.CHILD_NUMBER
    FROM RRS_SITE_GROUP_MEMBERS_TEMP RSGMT2
    START WITH RSGMT2.PARENT_ID = p_root_id
    CONNECT BY PRIOR RSGMT2.CHILD_ID = RSGMT2.PARENT_ID);

BEGIN

  SAVEPOINT Create_Hierarchy_Members;

  --initialize the return status
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --insert new row into RRS_SITE_GROUP_MEMBERS table
  INSERT INTO RRS_SITE_GROUP_MEMBERS
	(
		SITE_GROUP_VERSION_ID,
		SITE_GROUP_ID,
		PARENT_MEMBER_ID,
		CHILD_MEMBER_ID,
		DELETED_FLAG,
		OBJECT_VERSION_NUMBER,
		CREATED_BY,
		CREATION_DATE,
		LAST_UPDATED_BY,
		LAST_UPDATE_DATE,
		LAST_UPDATE_LOGIN,
		SEQUENCE_NUMBER
	)
  VALUES( p_hier_version_id,
          p_hier_id,
          -1,
          p_root_id,
          'N',
          1,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          null);

  /*
  IF SQL%NOTFOUND THEN
    RAISE e_insert_failed;
  END IF;*/

  IF p_hier_members_tab IS NOT NULL THEN --members list is specify
    --delete rows in RRS_SITE_GROUP_MEMBERS_TEMP
    DELETE FROM RRS_SITE_GROUP_MEMBERS_TEMP;

    FOR i in p_hier_members_tab.FIRST..p_hier_members_tab.LAST LOOP

			IF p_hier_members_tab(i).child_object_type <> 'SITE' AND
          p_hier_members_tab(i).child_object_type <> 'NODE' THEN
        --RRS_INVALID_TYPE
        FND_MESSAGE.set_name('RRS', 'RRS_INVALID_TYPE');
        FND_MESSAGE.set_token('TYPE', p_hier_members_tab(i).child_object_type);
        FND_MSG_PUB.add;
        --dbms_output.put_line('invalid transaction type');
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      INSERT INTO RRS_SITE_GROUP_MEMBERS_TEMP
			(
				PARENT_TYPE,
				PARENT_ID,
				PARENT_NUMBER,
				PARENT_PURPOSE_CODE,
				CHILD_TYPE,
				CHILD_ID,
				CHILD_NUMBER,
				CHILD_PURPOSE_CODE,
				SEQUENCE_NUMBER,
				CHILD_NODE_NAME,
				CHILD_NODE_DESCRIPTION
			)
      VALUES( p_hier_members_tab(i).parent_object_type,
              p_hier_members_tab(i).parent_id,
              p_hier_members_tab(i).parent_id_number,
              NULL,
              p_hier_members_tab(i).child_object_type,
              p_hier_members_tab(i).child_id,
              p_hier_members_tab(i).child_id_number,
              p_hier_members_tab(i).child_node_purpose_code,
              p_hier_members_tab(i).child_seq_number,
              p_hier_members_tab(i).child_node_name,
              p_hier_members_tab(i).child_node_description
              );
      /*
      IF SQL%NOTFOUND THEN
        RAISE e_insert_failed;
      END IF;*/
    END LOOP;

    --check the number of root and the purpose code of the root node
    BEGIN
      SELECT RSGMT.CHILD_ID, RSGMT.CHILD_NUMBER
      INTO v_root_id, v_root_number
      FROM RRS_SITE_GROUP_MEMBERS_TEMP RSGMT
      WHERE (RSGMT.PARENT_ID = -1 OR RSGMT.PARENT_TYPE = 'NONE')
      AND (RSGMT.CHILD_ID IS NOT NULL OR RSGMT.CHILD_NUMBER IS NOT NULL)
      AND RSGMT.CHILD_TYPE = 'NODE';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --RRS_NO_ROOT_FOUND
        FND_MESSAGE.set_name('RRS', 'RRS_NO_ROOT_FOUND');
        FND_MSG_PUB.add;
        --dbms_output.put_line('no root found');
        RAISE FND_API.G_EXC_ERROR;
      WHEN TOO_MANY_ROWS THEN
        --RRS_MANY_ROOTS_FOUND
        FND_MESSAGE.set_name('RRS', 'RRS_MANY_ROOTS_FOUND');
        FND_MSG_PUB.add;
        --dbms_output.put_line('too many roots found');
        RAISE FND_API.G_EXC_ERROR;
    END;

    --validate the root number user input with the one in DB
    IF (p_root_number IS NOT NULL AND v_root_number IS NOT NULL)
        AND p_root_number <> v_root_number THEN
      --RRS_NO_ROOT_FOUND
      FND_MESSAGE.set_name('RRS', 'RRS_NO_ROOT_FOUND');
      FND_MSG_PUB.add;
      --dbms_output.put_line('no root found');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF v_root_id IS NOT NULL AND p_root_id <> v_root_id THEN
      --RRS_NO_ROOT_FOUND
      FND_MESSAGE.set_name('RRS', 'RRS_NO_ROOT_FOUND');
      FND_MSG_PUB.add;
      --dbms_output.put_line('no root found');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_root_number IS NULL AND v_root_number IS NOT NULL THEN
      SELECT COUNT(*)
      INTO v_count
      FROM RRS_SITE_GROUP_NODES_VL
      WHERE NODE_IDENTIFICATION_NUMBER = v_root_number
      AND SITE_GROUP_NODE_ID <> p_root_id;

      IF v_count <> 0 THEN
        --RRS_NODE_EXISTS
        FND_MESSAGE.set_name('RRS', 'RRS_NODE_EXISTS');
        FND_MESSAGE.set_token('NODE_ID_NUM', v_root_number);
        FND_MSG_PUB.add;
        --dbms_output.put_line('node number already exists '||v_root_number);
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --update the root node number
      UPDATE RRS_SITE_GROUP_NODES_B
      SET NODE_IDENTIFICATION_NUMBER = v_root_number
      WHERE SITE_GROUP_NODE_ID = p_root_id;
    END IF;

    --delete the root node record
    DELETE FROM RRS_SITE_GROUP_MEMBERS_TEMP
    WHERE (PARENT_ID = -1 OR PARENT_TYPE = 'NONE')
    AND (CHILD_ID IS NOT NULL OR CHILD_NUMBER IS NOT NULL)
    AND CHILD_TYPE = 'NODE';

    --validate id/number
    --case1: both null
    SELECT COUNT(*)
    INTO v_count
    FROM RRS_SITE_GROUP_MEMBERS_TEMP
    WHERE (PARENT_ID IS NULL AND PARENT_NUMBER IS NULL)
    OR (CHILD_ID IS NULL AND CHILD_NUMBER IS NULL);

    IF v_count <> 0 THEN
      --RRS_ID_NUMBER_BOTH_NULL
      FND_MESSAGE.set_name('RRS', 'RRS_ID_NUMBER_BOTH_NULL');
      FND_MSG_PUB.add;
      --dbms_output.put_line('Id and number cannot both be NULL');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --case2: both not null
    --dbms_output.put_line('before case2');

    OPEN validate_p_id_num_cursor;
    LOOP
      FETCH validate_p_id_num_cursor INTO v_id, v_num;
      EXIT WHEN validate_p_id_num_cursor%NOTFOUND OR validate_p_id_num_cursor%NOTFOUND IS NULL;
      --RRS_INVALID_ID_NUMBER_PAIR
      FND_MESSAGE.set_name('RRS', 'RRS_INVALID_ID_NUMBER_PAIR');
      FND_MESSAGE.set_token('ID', v_id);
      FND_MESSAGE.set_token('NUM', v_num);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Invalid pair of id/number: '||v_id||'/'||v_num);
      x_return_status := FND_API.G_RET_STS_ERROR;
    END LOOP;
    CLOSE validate_p_id_num_cursor;

    OPEN validate_c_id_num_cursor;
    LOOP
      FETCH validate_c_id_num_cursor INTO v_id, v_num;
      EXIT WHEN validate_c_id_num_cursor%NOTFOUND OR validate_c_id_num_cursor%NOTFOUND IS NULL;
      --RRS_INVALID_ID_NUMBER_PAIR
      FND_MESSAGE.set_name('RRS', 'RRS_INVALID_ID_NUMBER_PAIR');
      FND_MESSAGE.set_token('ID', v_id);
      FND_MESSAGE.set_token('NUM', v_num);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Invalid pair of id/number: '||v_id||'/'||v_num);
      x_return_status := FND_API.G_RET_STS_ERROR;
    END LOOP;
    CLOSE validate_c_id_num_cursor;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    --check for non-existing id
    --dbms_output.put_line('before check non-existing id');
    OPEN validate_p_id_cursor;
    LOOP
      FETCH validate_p_id_cursor INTO v_type, v_id, v_num;
      EXIT WHEN validate_p_id_cursor%NOTFOUND OR validate_p_id_cursor%NOTFOUND IS NULL;
      --RRS_NO_ID_FOUND
      FND_MESSAGE.set_name('RRS', 'RRS_NO_ID_FOUND');
      FND_MESSAGE.set_token('ID', v_id);
      FND_MESSAGE.set_token('TYPE', v_type);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Non-existing type/id: '||v_type||'/'||v_id);
      x_return_status := FND_API.G_RET_STS_ERROR;
    END LOOP;
    CLOSE validate_p_id_cursor;

    OPEN validate_c_id_cursor;
    LOOP
      FETCH validate_c_id_cursor INTO v_type, v_id, v_num;
      EXIT WHEN validate_c_id_cursor%NOTFOUND OR validate_c_id_cursor%NOTFOUND IS NULL;
      --RRS_NO_ID_FOUND
      FND_MESSAGE.set_name('RRS', 'RRS_NO_ID_FOUND');
      FND_MESSAGE.set_token('ID', v_id);
      FND_MESSAGE.set_token('TYPE', v_type);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Non-existing type/id: '||v_type||'/'||v_id);
      x_return_status := FND_API.G_RET_STS_ERROR;
    END LOOP;
    CLOSE validate_c_id_cursor;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    --create non-existing node
    --dbms_output.put_line('before creat new node');
    FOR node_rec IN new_nodes_cursor LOOP
      --dbms_output.put_line('Inside new node');
      /*
      IF node_rec.CHILD_NODE_NAME IS NULL THEN
        --RRS_NULL_NAME
        --dbms_output.put_line('New node name cannot be null');
        RAISE e_other;
      END IF;*/

      Create_Hierarchy_Node(
        p_number => node_rec.CHILD_NUMBER,
        p_name => node_rec.CHILD_NODE_NAME,
        p_purpose_code => node_rec.CHILD_PURPOSE_CODE,
        p_description => node_rec.CHILD_NODE_DESCRIPTION,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

    END LOOP;

    --case3: either id/number is null
    --set the parent_id
    --dbms_output.put_line('before case3 update parent id/num');
    UPDATE RRS_SITE_GROUP_MEMBERS_TEMP RSGMT
    SET PARENT_ID = (
      SELECT DECODE(PARENT_TYPE,'SITE', SITE_ID, SITE_GROUP_NODE_ID)
      FROM RRS_SITES_VL RSV, RRS_SITE_GROUP_NODES_VL RSGNV, RRS_SITE_GROUP_MEMBERS_TEMP RSGMT2
      WHERE RSGMT2.PARENT_NUMBER =  RSV.SITE_IDENTIFICATION_NUMBER(+)
      AND RSGMT2.PARENT_NUMBER = RSGNV.NODE_IDENTIFICATION_NUMBER(+)
      AND RSGMT.ROWID = RSGMT2.ROWID)
    WHERE PARENT_ID IS NULL;
    --set the parent_number
    UPDATE RRS_SITE_GROUP_MEMBERS_TEMP RSGMT
    SET PARENT_NUMBER = (
      SELECT DECODE(PARENT_TYPE,'SITE', SITE_IDENTIFICATION_NUMBER, NODE_IDENTIFICATION_NUMBER)
      FROM RRS_SITES_VL RSV, RRS_SITE_GROUP_NODES_VL RSGNV, RRS_SITE_GROUP_MEMBERS_TEMP RSGMT2
      WHERE RSGMT2.PARENT_ID =  RSV.SITE_ID(+)
      AND RSGMT2.PARENT_ID = RSGNV.SITE_GROUP_NODE_ID(+)
      AND RSGMT.ROWID = RSGMT2.ROWID)
    WHERE PARENT_NUMBER IS NULL;
    --set the child_id
    --dbms_output.put_line('before case3 update child id/num');
    UPDATE RRS_SITE_GROUP_MEMBERS_TEMP RSGMT
    SET CHILD_ID = (
      SELECT DECODE(CHILD_TYPE,'SITE', SITE_ID, SITE_GROUP_NODE_ID)
      FROM RRS_SITES_VL RSV, RRS_SITE_GROUP_NODES_VL RSGNV, RRS_SITE_GROUP_MEMBERS_TEMP RSGMT2
      WHERE RSGMT2.CHILD_NUMBER =  RSV.SITE_IDENTIFICATION_NUMBER(+)
      AND RSGMT2.CHILD_NUMBER = RSGNV.NODE_IDENTIFICATION_NUMBER(+)
      AND RSGMT.ROWID = RSGMT2.ROWID)
    WHERE CHILD_ID IS NULL;
    --set the child_number
    UPDATE RRS_SITE_GROUP_MEMBERS_TEMP RSGMT
    SET CHILD_NUMBER = (
      SELECT DECODE(CHILD_TYPE,'SITE', SITE_IDENTIFICATION_NUMBER, NODE_IDENTIFICATION_NUMBER)
      FROM RRS_SITES_VL RSV, RRS_SITE_GROUP_NODES_VL RSGNV, RRS_SITE_GROUP_MEMBERS_TEMP RSGMT2
      WHERE RSGMT2.CHILD_ID =  RSV.SITE_ID(+)
      AND RSGMT2.CHILD_ID = RSGNV.SITE_GROUP_NODE_ID(+)
      AND RSGMT.ROWID = RSGMT2.ROWID)
    WHERE CHILD_NUMBER IS NULL;

    --check for duplicated site/node number
    --dbms_output.put_line('before check duplicated number');
    OPEN validate_dup_number_cursor;
    LOOP
      FETCH validate_dup_number_cursor INTO v_type, v_num;
      EXIT WHEN validate_dup_number_cursor%NOTFOUND OR validate_dup_number_cursor%NOTFOUND IS NULL;
      --RRS_DUPLICATED_NUMBER
      FND_MESSAGE.set_name('RRS', 'RRS_DUPLICATED_NUMBER');
      FND_MESSAGE.set_token('NUM', v_num);
      FND_MESSAGE.set_token('TYPE', v_type);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Duplicated type/num: '||v_type||'/'||v_num);
      x_return_status := FND_API.G_RET_STS_ERROR;
    END LOOP;
    CLOSE validate_dup_number_cursor;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --check for invalid site num
    --dbms_output.put_line('before check invalid site num');
    OPEN validate_num_cursor;
    LOOP
      FETCH validate_num_cursor INTO v_num, v_type;
      EXIT WHEN validate_num_cursor%NOTFOUND OR validate_num_cursor%NOTFOUND IS NULL;
      --RRS_NO_NUM_FOUND
      FND_MESSAGE.set_name('RRS', 'RRS_NO_NUM_FOUND');
      FND_MESSAGE.set_token('NUM', v_num);
      FND_MESSAGE.set_token('TYPE', v_type);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Invalid num: '||v_num);
      x_return_status := FND_API.G_RET_STS_ERROR;
    END LOOP;
    CLOSE validate_num_cursor;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --check for site template
    --dbms_output.put_line('before check site template');
    OPEN validate_site_template_cursor;
    LOOP
      FETCH validate_site_template_cursor INTO v_num;
      EXIT WHEN validate_site_template_cursor%NOTFOUND OR validate_site_template_cursor%NOTFOUND IS NULL;
      --RRS_SITE_TEMPLATE
      FND_MESSAGE.set_name('RRS', 'RRS_SITE_TEMPLATE');
      FND_MESSAGE.set_token('SITE_ID_NUM', v_num);
      FND_MSG_PUB.add;
      --dbms_output.put_line('site is a template: '||v_num);
      x_return_status := FND_API.G_RET_STS_ERROR;
    END LOOP;
    CLOSE validate_site_template_cursor;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --check for parent site/node does not exist in the hierarchy
    OPEN validate_p_in_hier_curosr;
    LOOP
      FETCH validate_p_in_hier_curosr INTO v_type, v_num;
      EXIT WHEN validate_p_in_hier_curosr%NOTFOUND OR validate_p_in_hier_curosr%NOTFOUND IS NULL;
      --RRS_HIER_NOT_CONNECTED
      FND_MESSAGE.set_name('RRS', 'RRS_HIER_NOT_CONNECTED');
      FND_MESSAGE.set_token('NUM', v_num);
      FND_MESSAGE.set_token('TYPE', v_type);
      FND_MSG_PUB.add;
      --dbms_output.put_line('No parent found type/num: '||v_type||'/'||v_num);
      x_return_status := FND_API.G_RET_STS_ERROR;
    END LOOP;
    CLOSE validate_p_in_hier_curosr;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --check for duplicated node name under a same parent
    --dbms_output.put_line('before check duplicated node name');
    OPEN validate_node_name_cursor;
    LOOP
      FETCH validate_node_name_cursor INTO v_node_name;
      EXIT WHEN validate_node_name_cursor%NOTFOUND OR validate_node_name_cursor%NOTFOUND IS NULL;
      --RRS_DUPLICATED_NODE_NAME
      FND_MESSAGE.set_name('RRS', 'RRS_DUPLICATED_NODE_NAME');
      FND_MESSAGE.set_token('NODE_NAME', v_node_name);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Duplicated node name under a same parent: '||v_node_name);
      x_return_status := FND_API.G_RET_STS_ERROR;
    END LOOP;
    CLOSE validate_node_name_cursor;

    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --update nodes
    --dbms_output.put_line('before update nodes');
    FOR node_rec IN update_nodes_cursor LOOP
      --dbms_output.put_line('Inside update nodes');

      Update_Hierarchy_Node(
        p_number => node_rec.CHILD_NUMBER,
        p_name => node_rec.CHILD_NODE_NAME,
        p_purpose_code => node_rec.CHILD_PURPOSE_CODE,
        p_description => node_rec.CHILD_NODE_DESCRIPTION,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

    END LOOP;

    --RulesFwk
    IF p_hier_purpose_code IS NOT NULL THEN
      --default the purpose code for parent
      --dbms_output.put_line('before defaulting parent purpose code');
      UPDATE RRS_SITE_GROUP_MEMBERS_TEMP RSGMT
      SET PARENT_PURPOSE_CODE = (
        SELECT NVL(RSU.SITE_USE_TYPE_CODE, RSGNV.NODE_PURPOSE_CODE)
        FROM RRS_SITE_GROUP_MEMBERS_TEMP RSGMT2, RRS_SITE_USES RSU, RRS_SITE_GROUP_NODES_VL RSGNV
        WHERE RSGMT2.PARENT_ID = RSU.SITE_ID(+)
        AND RSU.IS_PRIMARY_FLAG(+) = 'Y'
        AND RSGMT2.PARENT_ID = RSGNV.SITE_GROUP_NODE_ID(+)
        AND RSGMT.ROWID = RSGMT2.ROWID);

      --default the purpose code for child
      --dbms_output.put_line('before defaulting child purpose code');
      UPDATE RRS_SITE_GROUP_MEMBERS_TEMP RSGMT
      SET CHILD_PURPOSE_CODE = (
        SELECT NVL(RSU.SITE_USE_TYPE_CODE, RSGNV.NODE_PURPOSE_CODE)
        FROM RRS_SITE_GROUP_MEMBERS_TEMP RSGMT2, RRS_SITE_USES RSU, RRS_SITE_GROUP_NODES_VL RSGNV
        WHERE RSGMT2.CHILD_ID = RSU.SITE_ID(+)
        AND RSU.IS_PRIMARY_FLAG(+) = 'Y'
        AND RSGMT2.CHILD_ID = RSGNV.SITE_GROUP_NODE_ID(+)
        AND RSU.IS_PRIMARY_FLAG(+) = 'Y'
        AND RSGMT.ROWID = RSGMT2.ROWID);

      Validate_Rules_For_Members(
        p_hier_purpose_code => p_hier_purpose_code,
        x_return_status => x_return_status,
        x_msg_data => x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

    END IF;

    --insert into members table
    --dbms_output.put_line('before inserting into members');
    FOR mem_rec IN new_members_cursor LOOP
      INSERT INTO RRS_SITE_GROUP_MEMBERS
			(
				SITE_GROUP_VERSION_ID,
				SITE_GROUP_ID,
				PARENT_MEMBER_ID,
				CHILD_MEMBER_ID,
				DELETED_FLAG,
				OBJECT_VERSION_NUMBER,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN,
				SEQUENCE_NUMBER
			)
      VALUES( p_hier_version_id,
              p_hier_id,
              mem_rec.PARENT_ID,
              mem_rec.CHILD_ID,
              'N',
              1,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              mem_rec.SEQUENCE_NUMBER);
    END LOOP;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Hierarchy_Members;
    x_msg_count := FND_MSG_PUB.Count_Msg;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_Hierarchy_Members;
    x_msg_data := G_PKG_NAME || '.Create_Hierarchy_Members:' || x_msg_data;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    ROLLBACK TO Create_Hierarchy_Members;
    x_msg_data := G_PKG_NAME || '.Create_Hierarchy_Members:' || SQLERRM;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Create_Hierarchy_Members;

procedure Update_Hierarchy_Coarse(
        p_api_version IN NUMBER DEFAULT 1,
        p_hier_name IN VARCHAR2,
        p_hier_new_name IN VARCHAR2 DEFAULT NULL,
        p_hier_description IN VARCHAR2 DEFAULT NULL,
        p_hier_purpose_code IN VARCHAR2 DEFAULT NULL,
        p_hier_start_date IN DATE DEFAULT NULL,
        p_hier_end_date IN DATE DEFAULT NULL,
        p_hier_members_tab IN RRS_HIER_MEMBERS_COARSE_TAB DEFAULT NULL,
        p_nullify_flag IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        x_return_status OUT NOCOPY varchar2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2
)IS

  v_count NUMBER;
  v_hier_id NUMBER;
  v_hier_version_id NUMBER;
  v_root_number VARCHAR2(30);
  v_root_id NUMBER;
  v_purpose_code VARCHAR2(30);
BEGIN
  SAVEPOINT Update_Hierarchy_Coarse;

	IF p_nullify_flag <> FND_API.G_FALSE
		AND p_nullify_flag <> FND_API.G_TRUE THEN
		--RRS_INVALID_FLAG
    FND_MESSAGE.set_name('RRS', 'RRS_INVALID_FLAG');
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
	END IF;

  BEGIN
    SELECT SITE_GROUP_ID
    INTO v_hier_id
    FROM RRS_SITE_GROUPS_VL RSGV
    WHERE RSGV.NAME = p_hier_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    --RRS_NO_HIER_FOUND
    FND_MESSAGE.set_name('RRS', 'RRS_NO_HIER_FOUND');
    FND_MESSAGE.set_token('HIERARCHY_NAME', p_hier_name);
    FND_MSG_PUB.add;
    --dbms_output.put_line('invalid hier name');
    RAISE FND_API.G_EXC_ERROR;
  END;

  BEGIN
    SELECT RSGM.CHILD_MEMBER_ID, RSGNV.NODE_IDENTIFICATION_NUMBER
    INTO v_root_id, v_root_number
    FROM RRS_SITE_GROUP_MEMBERS RSGM, RRS_SITE_GROUP_NODES_VL RSGNV
    WHERE RSGM.SITE_GROUP_ID = v_hier_id
    AND RSGM.PARENT_MEMBER_ID = -1
    AND RSGM.CHILD_MEMBER_ID = RSGNV.SITE_GROUP_NODE_ID
    AND RSGNV.NODE_PURPOSE_CODE = 'ROOT';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    --RRS_NO_ROOT_FOUND
    FND_MESSAGE.set_name('RRS', 'RRS_NO_ROOT_FOUND');
    FND_MSG_PUB.add;
    --dbms_output.put_line('root node not found in members table');
    RAISE FND_API.G_EXC_ERROR;
  END;

  BEGIN
    SELECT SITE_GROUP_VERSION_ID
    INTO v_hier_version_id
    FROM RRS_SITE_GROUP_VERSIONS
    WHERE SITE_GROUP_ID = v_hier_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    --RRS_NO_HIER_VERSION_FOUND
    FND_MESSAGE.set_name('RRS', 'RRS_NO_HIER_VERSION_FOUND');
    FND_MESSAGE.set_token('HIERARCHY_NAME', p_hier_name);
    FND_MSG_PUB.add;
    --dbms_output.put_line('hier version id not found');
    RAISE FND_API.G_EXC_ERROR;
  END;

  --default the purpose code when nuulify flag is false and purpose code is not specified
  IF NOT FND_API.To_Boolean(p_nullify_flag) AND p_hier_purpose_code IS NULL THEN
    SELECT GROUP_PURPOSE_CODE
    INTO v_purpose_code
    FROM RRS_SITE_GROUPS_B RSGB
    WHERE RSGB.SITE_GROUP_ID = v_hier_id;
  ELSE
    v_purpose_code := p_hier_purpose_code;
  END IF;

  --dbms_output.put_line(v_hier_version_id||' '||v_hier_id||' '||v_root_id||' '||v_purpose_code);

  --dbms_output.put_line('before update hierarchy header');
  Update_Hierarchy_Header(
        p_name => p_hier_name,
        p_new_name => p_hier_new_name,
        p_description => p_hier_description,
        p_purpose_code => v_purpose_code,
        p_start_date => p_hier_start_date,
        p_end_date => p_hier_end_date,
        p_nullify_flag => p_nullify_flag,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data);

  --dbms_output.put_line(x_return_status);
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
  END IF;

  IF p_hier_members_tab IS NOT NULL OR FND_API.To_Boolean(p_nullify_flag) THEN

    --dbms_output.put_line('before delete members table');
    DELETE FROM RRS_SITE_GROUP_MEMBERS
    WHERE SITE_GROUP_ID = v_hier_id;

    --dbms_output.put_line('before create hierarchy members');
    Create_Hierarchy_Members(
          p_hier_version_id => v_hier_version_id,
          p_hier_id => v_hier_id,
          p_root_number => v_root_number,
          p_root_id => v_root_id,
          p_hier_purpose_code => v_purpose_code,
          p_hier_members_tab => p_hier_members_tab,
          x_return_status => x_return_status,
          x_msg_count => x_msg_count,
          x_msg_data => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

  END IF;

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Update_Hierarchy_Coarse;
    x_msg_count := FND_MSG_PUB.Count_Msg;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Update_Hierarchy_Coarse;
    x_msg_data := G_PKG_NAME || '.Update_Hierarchy_Coarse:' || x_msg_data;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    ROLLBACK TO Update_Hierarchy_Coarse;
    x_msg_data := G_PKG_NAME || '.Update_Hierarchy_Coarse:' || SQLERRM;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Update_Hierarchy_Coarse;

procedure Update_Hierarchy_Fine(
        p_api_version IN NUMBER DEFAULT 1,
        p_hier_members_rec IN RRS_HIER_MEMBERS_FINE_REC,
        p_commit IN VARCHAR2 DEFAULT FND_API.G_FALSE,
        x_return_status OUT NOCOPY varchar2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2
)IS

  v_source_hier_id NUMBER;
  v_dest_hier_id NUMBER;
  v_dest_hier_version_id NUMBER;
  v_dest_hier_purpose_code VARCHAR2(30);
  v_child_purpose_code VARCHAR2(30);
  v_dest_parent_purpose_code VARCHAR2(30);
  v_count NUMBER;
  v_child_id NUMBER;
  v_dest_parent_id NUMBER;
  v_source_parent_id NUMBER;
  v_child_name VARCHAR2(30);
  v_p_num VARCHAR2(30);
  v_p_type VARCHAR2(30);
  v_c_num VARCHAR2(30);
  v_c_type VARCHAR2(30);
  v_flag VARCHAR2(30);

  CURSOR parent_child_cursor IS
  SELECT DECODE(RSV.SITE_ID, NULL, 'NODE', 'SITE') AS P_TYPE,
         RSGM.PARENT_MEMBER_ID AS P_ID,
         NVL(RSV.SITE_IDENTIFICATION_NUMBER, RSGNV.NODE_IDENTIFICATION_NUMBER) AS P_NUMBER,
         DECODE(RSV.SITE_ID, NULL, RSGNV.NODE_PURPOSE_CODE, RSU.SITE_USE_TYPE_CODE) AS P_PURPOSE_CODE,
         DECODE(RSV2.SITE_ID, NULL, 'NODE', 'SITE') AS C_TYPE,
         RSGM.CHILD_MEMBER_ID AS C_ID,
         NVL(RSV2.SITE_IDENTIFICATION_NUMBER, RSGNV2.NODE_IDENTIFICATION_NUMBER) AS C_NUMBER,
         DECODE(RSV2.SITE_ID, NULL, RSGNV2.NODE_PURPOSE_CODE, RSU2.SITE_USE_TYPE_CODE) AS C_PURPOSE_CODE,
         RSGM.SEQUENCE_NUMBER AS C_SEQ_NUMBER
  FROM RRS_SITE_GROUP_MEMBERS RSGM,
       RRS_SITE_GROUP_NODES_VL RSGNV,
       RRS_SITES_VL RSV, RRS_SITE_USES RSU,
       RRS_SITE_GROUP_NODES_VL RSGNV2,
       RRS_SITES_VL RSV2,
       RRS_SITE_USES RSU2
  WHERE RSGM.PARENT_MEMBER_ID = RSV.SITE_ID(+)
  AND RSGM.PARENT_MEMBER_ID = RSU.SITE_ID(+)
  AND NVL(RSU.IS_PRIMARY_FLAG, 'Y') = 'Y'
  AND RSGM.PARENT_MEMBER_ID = RSGNV.SITE_GROUP_NODE_ID(+)
  AND RSGM.CHILD_MEMBER_ID = RSV2.SITE_ID(+)
  AND RSGM.CHILD_MEMBER_ID = RSU2.SITE_ID(+)
  AND NVL(RSU2.IS_PRIMARY_FLAG, 'Y') = 'Y'
  AND RSGM.CHILD_MEMBER_ID = RSGNV2.SITE_GROUP_NODE_ID(+)
  START WITH CHILD_MEMBER_ID = v_child_id
  AND SITE_GROUP_ID = v_source_hier_id
  CONNECT BY PRIOR CHILD_MEMBER_ID = PARENT_MEMBER_ID
  AND SITE_GROUP_ID = v_source_hier_id;

  CURSOR new_members_cursor IS
  SELECT *
  FROM RRS_SITE_GROUP_MEMBERS_TEMP;

  CURSOR validate_rules_cursor IS
  SELECT PARENT_TYPE, PARENT_NUMBER, CHILD_TYPE, CHILD_NUMBER
  FROM RRS_SITE_GROUP_MEMBERS_TEMP
  WHERE CHILD_ID NOT IN (
    SELECT CHILD_ID
    FROM RRS_SITE_GROUP_MEMBERS_TEMP RSGMT, RRS_GROUP_RULES RGR
    WHERE RGR.SITE_GROUP_TYPE_CODE = 'H'
    AND RGR.GROUP_PURPOSE_CODE = v_dest_hier_purpose_code
    AND RGR.RELATIONSHIP_TYPE = 'PARENT_CHILD'
    AND RSGMT.PARENT_TYPE = RGR.OBJECT1
    AND RSGMT.PARENT_PURPOSE_CODE = RGR.CLASSIFICATION_CODE1
    AND RSGMT.CHILD_TYPE = RGR.OBJECT2
    AND RSGMT.CHILD_PURPOSE_CODE = RGR.CLASSIFICATION_CODE2);

BEGIN
  SAVEPOINT Update_Hierarchy_Fine;

  --validate dest hier name
  --dbms_output.put_line('before validate dest hier name');
  --get dest hier id
  BEGIN
    SELECT SITE_GROUP_ID, GROUP_PURPOSE_CODE
    INTO v_dest_hier_id, v_dest_hier_purpose_code
    FROM RRS_SITE_GROUPS_VL RSGV
    WHERE RSGV.NAME = p_hier_members_rec.dest_hier_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --RRS_NO_HIER_FOUND
      FND_MESSAGE.set_name('RRS', 'RRS_NO_HIER_FOUND');
      FND_MESSAGE.set_token('HIERARCHY_NAME', p_hier_members_rec.dest_hier_name);
      FND_MSG_PUB.add;
      --dbms_output.put_line('invalid dest hier name: '||p_hier_members_rec.dest_hier_name);
      RAISE FND_API.G_EXC_ERROR;
  END;
  --get dest hier version id
  --dbms_output.put_line('before get dest hier version id');
  BEGIN
    SELECT SITE_GROUP_VERSION_ID
    INTO v_dest_hier_version_id
    FROM RRS_SITE_GROUP_VERSIONS
    WHERE SITE_GROUP_ID = v_dest_hier_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --RRS_NO_HIER_VERSION_FOUND
      FND_MESSAGE.set_name('RRS', 'RRS_NO_HIER_VERSION_FOUND');
      FND_MESSAGE.set_token('HIERARCHY_NAME', p_hier_members_rec.dest_hier_name);
      FND_MSG_PUB.add;
      --dbms_output.put_line('version id not found: '||p_hier_members_rec.dest_hier_name);
      RAISE FND_API.G_EXC_ERROR;
  END;

  --validate child number
  --1. child number cannot be null
  --2. cannot transact on root node
  --3. site/node must exist
  --4. cannot be a site template
  --dbms_output.put_line('before validate child number');
  IF p_hier_members_rec.child_id_number IS NULL THEN
    --RRS_NULL_CHILD_NUMBER
    FND_MESSAGE.set_name('RRS', 'RRS_NULL_CHILD_NUMBER');
    FND_MSG_PUB.add;
    --dbms_output.put_line('child number cannot be null');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_hier_members_rec.child_object_type = 'NODE' THEN
    BEGIN
      SELECT SITE_GROUP_NODE_ID, NODE_PURPOSE_CODE, NAME
      INTO v_child_id, v_child_purpose_code, v_child_name
      FROM RRS_SITE_GROUP_NODES_VL
      WHERE NODE_IDENTIFICATION_NUMBER = p_hier_members_rec.child_id_number;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --RRS_NO_NODE_FOUND
        FND_MESSAGE.set_name('RRS', 'RRS_NO_NODE_FOUND');
        FND_MESSAGE.set_token('NODE_ID_NUM', p_hier_members_rec.child_id_number);
        FND_MSG_PUB.add;
        --dbms_output.put_line('invalid node number: '|| p_hier_members_rec.child_id_number);
        RAISE FND_API.G_EXC_ERROR;
    END;
    IF v_child_purpose_code = 'ROOT' THEN
      --RRS_TRANSACT_ROOT
      FND_MESSAGE.set_name('RRS', 'RRS_TRANSACT_ROOT');
      FND_MSG_PUB.add;
      --dbms_output.put_line('cannot transact on root node');
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSIF p_hier_members_rec.child_object_type = 'SITE' THEN
    BEGIN
      SELECT RSV.SITE_ID, RSU.SITE_USE_TYPE_CODE, RSV.IS_TEMPLATE_FLAG
      INTO v_child_id, v_child_purpose_code, v_flag
      FROM RRS_SITES_VL RSV, RRS_SITE_USES RSU
      WHERE RSV.SITE_IDENTIFICATION_NUMBER = p_hier_members_rec.child_id_number
      AND RSV.SITE_ID = RSU.SITE_ID(+)
      AND RSU.IS_PRIMARY_FLAG(+) = 'Y';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --RRS_NO_SITE_FOUND
        FND_MESSAGE.set_name('RRS', 'RRS_NO_SITE_FOUND');
        FND_MESSAGE.set_token('SITE_ID_NUM', p_hier_members_rec.child_id_number);
        FND_MSG_PUB.add;
        --dbms_output.put_line('invalid site number: '|| p_hier_members_rec.child_id_number);
        RAISE FND_API.G_EXC_ERROR;
    END;
    IF v_flag = 'Y' THEN
      --RRS_SITE_TEMPLATE
      FND_MESSAGE.set_name('RRS', 'RRS_SITE_TEMPLATE');
      FND_MESSAGE.set_token('SITE_ID_NUM', p_hier_members_rec.child_id_number);
      FND_MSG_PUB.add;
      --dbms_output.put_line('site is a template: '||p_hier_members_rec.child_id_number);
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  ELSE
    --RRS_INVALID_TYPE
    FND_MESSAGE.set_name('RRS', 'RRS_INVALID_TYPE');
    FND_MESSAGE.set_token('TYPE', p_hier_members_rec.child_object_type);
    FND_MSG_PUB.add;
    --dbms_output.put_line('Invalid child type: '||p_hier_members_rec.child_object_type);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --get parent id, parent purpose code and source hier id
  IF p_hier_members_rec.transaction_type = 'ADD'
  OR p_hier_members_rec.transaction_type = 'COPY'
  OR p_hier_members_rec.transaction_type = 'MOVE' THEN

    --validate dest parent number
    --1. parent number cannot be null
    --2. site/node must exist
    --3. site/node shuld appear in the hierarchy
    --dbms_output.put_line('before validate dest parent number');
    IF p_hier_members_rec.dest_parent_id_number IS NULL THEN
      --RRS_NULL_DEST_PARENT_NUMBER
      FND_MESSAGE.set_name('RRS', 'RRS_NULL_DEST_PARENT_NUMBER');
      FND_MSG_PUB.add;
      --dbms_output.put_line('dest parent number cannot be null');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF p_hier_members_rec.dest_parent_object_type = 'NODE' THEN
      BEGIN
        SELECT SITE_GROUP_NODE_ID, NODE_PURPOSE_CODE
        INTO v_dest_parent_id, v_dest_parent_purpose_code
        FROM RRS_SITE_GROUP_NODES_VL RSGNV, RRS_SITE_GROUP_MEMBERS RSGM
        WHERE RSGNV.NODE_IDENTIFICATION_NUMBER = p_hier_members_rec.dest_parent_id_number
        AND RSGNV.SITE_GROUP_NODE_ID = RSGM.CHILD_MEMBER_ID
        AND RSGM.SITE_GROUP_ID = v_dest_hier_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          --RRS_HIER_NO_NODE_FOUND
          FND_MESSAGE.set_name('RRS', 'RRS_HIER_NO_NODE_FOUND');
          FND_MESSAGE.set_token('NODE_ID_NUM', p_hier_members_rec.dest_parent_id_number);
          FND_MESSAGE.set_token('HIERARCHY_NAME', p_hier_members_rec.dest_hier_name);
          FND_MSG_PUB.add;
          --dbms_output.put_line('node does not exist or appear in the hierarchy: '|| p_hier_members_rec.dest_parent_id_number);
          RAISE FND_API.G_EXC_ERROR;
      END;
    ELSIF p_hier_members_rec.dest_parent_object_type = 'SITE' THEN
      BEGIN
        SELECT RSV.SITE_ID, RSU.SITE_USE_TYPE_CODE
        INTO v_dest_parent_id, v_dest_parent_purpose_code
        FROM RRS_SITES_VL RSV, RRS_SITE_USES RSU, RRS_SITE_GROUP_MEMBERS RSGM
        WHERE RSV.SITE_IDENTIFICATION_NUMBER = p_hier_members_rec.dest_parent_id_number
        AND RSV.SITE_ID = RSU.SITE_ID(+)
        AND RSU.IS_PRIMARY_FLAG(+) = 'Y'
        AND RSV.SITE_ID = RSGM.CHILD_MEMBER_ID
        AND RSGM.SITE_GROUP_ID = v_dest_hier_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          --RRS_HIER_NO_SITE_FOUND
          FND_MESSAGE.set_name('RRS', 'RRS_HIER_NO_SITE_FOUND');
          FND_MESSAGE.set_token('SITE_ID_NUM', p_hier_members_rec.dest_parent_id_number);
          FND_MESSAGE.set_token('HIERARCHY_NAME', p_hier_members_rec.dest_hier_name);
          FND_MSG_PUB.add;
          --dbms_output.put_line('site does not exist or appear in the hierarchy: '|| p_hier_members_rec.dest_parent_id_number);
          RAISE FND_API.G_EXC_ERROR;
      END;
    ELSE
      --RRS_INVALID_TYPE
      FND_MESSAGE.set_name('RRS', 'RRS_INVALID_TYPE');
      FND_MESSAGE.set_token('TYPE', p_hier_members_rec.dest_parent_object_type);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Invalid parent type: '||p_hier_members_rec.dest_parent_object_type);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END IF;

  --1. ADD
  IF p_hier_members_rec.transaction_type = 'ADD' THEN
    --dbms_output.put_line('Transaction ADD');
    --child id should not appear in the dest hier
    SELECT COUNT(*)
    INTO v_count
    FROM RRS_SITE_GROUP_MEMBERS
    WHERE CHILD_MEMBER_ID = v_child_id
    AND SITE_GROUP_ID = v_dest_hier_id;
    IF v_count <> 0 THEN
      --RRS_HIER_CHILD_EXISTS
      FND_MESSAGE.set_name('RRS', 'RRS_HIER_CHILD_EXISTS');
      FND_MESSAGE.set_token('NUM', p_hier_members_rec.child_id_number);
      FND_MESSAGE.set_token('TYPE', p_hier_members_rec.child_object_type);
      FND_MESSAGE.set_token('HIERARCHY_NAME', p_hier_members_rec.dest_hier_name);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Child already exists in the destination hierarchy: '||p_hier_members_rec.child_id_number);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --dbms_output.put_line(v_hier_purpose_code||' '||v_parent_purpose_code||' '||v_child_purpose_code);

    --RulesFwk
    --dbms_output.put_line('before RulesFwk');
    IF v_dest_hier_purpose_code IS NOT NULL THEN

      Validate_Rules_For_Child(
        p_hier_purpose_code => v_dest_hier_purpose_code,
        p_parent_id_number => p_hier_members_rec.dest_parent_id_number,
        p_parent_object_type => p_hier_members_rec.dest_parent_object_type,
        p_parent_purpose_code => v_dest_parent_purpose_code,
        p_child_id_number => p_hier_members_rec.child_id_number,
        p_child_object_type => p_hier_members_rec.child_object_type,
        p_child_purpose_code => v_child_purpose_code,
        x_return_status => x_return_status,
        x_msg_data => x_msg_data
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

    END IF;

    --add to members table
    --dbms_output.put_line('before add to members table');
    INSERT INTO RRS_SITE_GROUP_MEMBERS
		(
				SITE_GROUP_VERSION_ID,
				SITE_GROUP_ID,
				PARENT_MEMBER_ID,
				CHILD_MEMBER_ID,
				DELETED_FLAG,
				OBJECT_VERSION_NUMBER,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN,
				SEQUENCE_NUMBER
			)
    VALUES( v_dest_hier_version_id,
            v_dest_hier_id,
            v_dest_parent_id,
            v_child_id,
            'N',
            1,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            sysdate,
            fnd_global.user_id,
            p_hier_members_rec.child_seq_number);

  --2. REMOVE
  ELSIF p_hier_members_rec.transaction_type = 'REMOVE' THEN
    --dbms_output.put_line('Transaction REMOVE');
    --child id should appear in the destination hierarchy
    SELECT COUNT(*)
    INTO v_count
    FROM RRS_SITE_GROUP_MEMBERS
    WHERE SITE_GROUP_ID = v_dest_hier_id
    AND CHILD_MEMBER_ID = v_child_id;

    IF v_count = 0 THEN
      --RRS_HIER_NO_CHILD_FOUND
      FND_MESSAGE.set_name('RRS', 'RRS_HIER_NO_CHILD_FOUND');
      FND_MESSAGE.set_token('NUM', p_hier_members_rec.child_id_number);
      FND_MESSAGE.set_token('TYPE', p_hier_members_rec.child_object_type);
      FND_MESSAGE.set_token('HIERARCHY_NAME', p_hier_members_rec.dest_hier_name);
      FND_MSG_PUB.add;
      --dbms_output.put_line('Child does not appear in the destination hierarchy');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --remove the subtree in members table
    DELETE FROM RRS_SITE_GROUP_MEMBERS
    WHERE CHILD_MEMBER_ID IN (
      SELECT CHILD_MEMBER_ID
      FROM RRS_SITE_GROUP_MEMBERS
      START WITH CHILD_MEMBER_ID = v_child_id
      AND SITE_GROUP_ID = v_dest_hier_id
      CONNECT BY PRIOR CHILD_MEMBER_ID = PARENT_MEMBER_ID
      AND SITE_GROUP_ID = v_dest_hier_id)
    AND SITE_GROUP_ID = v_dest_hier_id;

  --3. COPY 4. MOVE
  ELSIF p_hier_members_rec.transaction_type = 'COPY'
  OR p_hier_members_rec.transaction_type = 'MOVE' THEN
    --dbms_output.put_line('Transaction '||p_hier_members_rec.transaction_type);
    --get source hier id
    BEGIN
      SELECT SITE_GROUP_ID
      INTO v_source_hier_id
      FROM RRS_SITE_GROUPS_VL
      WHERE NAME = p_hier_members_rec.source_hier_name;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --RRS_NO_HIER_FOUND
        FND_MESSAGE.set_name('RRS', 'RRS_NO_HIER_FOUND');
        FND_MESSAGE.set_token('HIERARCHY_NAME', p_hier_members_rec.source_hier_name);
        FND_MSG_PUB.add;
        --dbms_output.put_line('invalid source hier name: '||p_hier_members_rec.source_hier_name);
        RAISE FND_API.G_EXC_ERROR;
    END;

    --1. child id must appear in the source hierarchy
    --2. get source parent id
    BEGIN
      SELECT PARENT_MEMBER_ID
      INTO v_source_parent_id
      FROM RRS_SITE_GROUP_MEMBERS
      WHERE SITE_GROUP_ID = v_source_hier_id
      AND CHILD_MEMBER_ID = v_child_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --RRS_HIER_NO_CHILD_FOUND
        FND_MESSAGE.set_name('RRS', 'RRS_HIER_NO_CHILD_FOUND');
        FND_MESSAGE.set_token('NUM', p_hier_members_rec.child_id_number);
        FND_MESSAGE.set_token('TYPE', p_hier_members_rec.child_object_type);
        FND_MESSAGE.set_token('HIERARCHY_NAME', p_hier_members_rec.source_hier_name);
        FND_MSG_PUB.add;
        --dbms_output.put_line('Child does not appear in the source hierarchy');
        RAISE FND_API.G_EXC_ERROR;
    END;

    --source and dest hier cannot be the same for COPY transaction
    IF p_hier_members_rec.transaction_type = 'COPY'
    AND v_source_hier_id = v_dest_hier_id THEN
      --RRS_HIER_SAME_DEST_SOURCE
      FND_MESSAGE.set_name('RRS', 'RRS_HIER_SAME_DEST_SOURCE');
      FND_MSG_PUB.add;
      --dbms_output.put_line('dest hier cannot be the same as source hier');
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --cannot move into its subtree for MOVE transaction
    IF p_hier_members_rec.transaction_type = 'MOVE' THEN
      SELECT COUNT(*)
      INTO v_count
      FROM (
        SELECT CHILD_MEMBER_ID
        FROM RRS_SITE_GROUP_MEMBERS
        START WITH CHILD_MEMBER_ID = v_child_id
        AND SITE_GROUP_ID = v_source_hier_id
        CONNECT BY PRIOR CHILD_MEMBER_ID = PARENT_MEMBER_ID
        AND SITE_GROUP_ID = v_source_hier_id) TMP
      WHERE CHILD_MEMBER_ID = v_dest_parent_id;

      IF v_count <> 0 THEN
        --RRS_PARENT_DEST_UNDER_SOURCE
        FND_MESSAGE.set_name('RRS', 'RRS_PARENT_DEST_UNDER_SOURCE');
        FND_MSG_PUB.add;
        --dbms_output.put_line('Cannot move a site/node under its child');
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    --delete rows in RRS_SITE_GROUP_MEMBERS_TEMP
    DELETE FROM RRS_SITE_GROUP_MEMBERS_TEMP;

    FOR rec IN parent_child_cursor LOOP
      --check only when source and dest hier are different
      IF v_source_hier_id <> v_dest_hier_id THEN
        --validate child id. Should not appear in dest hier
        SELECT COUNT(*)
        INTO v_count
        FROM RRS_SITE_GROUP_MEMBERS
        WHERE CHILD_MEMBER_ID = rec.C_ID
        AND SITE_GROUP_ID = v_dest_hier_id;

        IF v_count <> 0 THEN
          --RRS_HIER_CHILD_EXISTS
          FND_MESSAGE.set_name('RRS', 'RRS_HIER_CHILD_EXISTS');
          FND_MESSAGE.set_token('NUM', p_hier_members_rec.child_id_number);
          FND_MESSAGE.set_token('TYPE', p_hier_members_rec.child_object_type);
          FND_MESSAGE.set_token('HIERARCHY_NAME', p_hier_members_rec.dest_hier_name);
          FND_MSG_PUB.add;
          --dbms_output.put_line('Child already exists in the destination hierarchy ');
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      --insert into members temp table
      IF rec.C_ID = v_child_id THEN --root node/site of the subtree

        --check for duplicated node name under a same parent
        IF p_hier_members_rec.child_object_type = 'NODE' THEN
          --dbms_output.put_line('before check duplicated node name');
          SELECT COUNT(*)
          INTO v_count
          FROM RRS_SITE_GROUP_MEMBERS RSGM, RRS_SITE_GROUP_NODES_VL RSGNV
          WHERE RSGM.SITE_GROUP_ID = v_dest_hier_id
          AND RSGM.PARENT_MEMBER_ID = v_dest_parent_id
          AND RSGM.CHILD_MEMBER_ID = RSGNV.SITE_GROUP_NODE_ID
          AND RSGNV.NAME = v_child_name;

          IF v_count <> 0 THEN
            --RRS_DUPLICATED_NODE_NAME
            FND_MESSAGE.set_name('RRS', 'RRS_DUPLICATED_NODE_NAME');
            FND_MESSAGE.set_token('NODE_NAME', v_child_name);
            FND_MSG_PUB.add;
            --dbms_output.put_line('Duplicated node names under the dest parent');
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;

        --dbms_output.put_line('before insert into temp table 1');
        INSERT INTO RRS_SITE_GROUP_MEMBERS_TEMP
				(
					PARENT_TYPE,
					PARENT_ID,
					PARENT_NUMBER,
					PARENT_PURPOSE_CODE,
					CHILD_TYPE,
					CHILD_ID,
					CHILD_NUMBER,
					CHILD_PURPOSE_CODE,
					SEQUENCE_NUMBER,
					CHILD_NODE_NAME,
					CHILD_NODE_DESCRIPTION
				)
        VALUES( p_hier_members_rec.dest_parent_object_type,
                v_dest_parent_id,
                p_hier_members_rec.dest_parent_id_number,
                v_dest_parent_purpose_code,
                p_hier_members_rec.child_object_type,
                v_child_id,
                p_hier_members_rec.child_id_number,
                v_child_purpose_code,
                p_hier_members_rec.child_seq_number,
                NULL,
                NULL
                );

      ELSE --other node/site in the subtree
        --dbms_output.put_line('before insert into temp table 2');
        INSERT INTO RRS_SITE_GROUP_MEMBERS_TEMP
				(
					PARENT_TYPE,
					PARENT_ID,
					PARENT_NUMBER,
					PARENT_PURPOSE_CODE,
					CHILD_TYPE,
					CHILD_ID,
					CHILD_NUMBER,
					CHILD_PURPOSE_CODE,
					SEQUENCE_NUMBER,
					CHILD_NODE_NAME,
					CHILD_NODE_DESCRIPTION
				)
        VALUES( rec.P_TYPE,
                rec.P_ID,
                rec.P_NUMBER,
                rec.P_PURPOSE_CODE,
                rec.C_TYPE,
                rec.C_ID,
                rec.C_NUMBER,
                rec.C_PURPOSE_CODE,
                rec.C_SEQ_NUMBER,
                NULL,
                NULL
                );
      END IF;
    END LOOP;

    --RulesFwk
    --dbms_output.put_line('before RulesFwk');
    IF v_dest_hier_purpose_code IS NOT NULL THEN

      Validate_Rules_For_Members(
        p_hier_purpose_code => v_dest_hier_purpose_code,
        x_return_status => x_return_status,
        x_msg_data => x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
      END IF;

    END IF;

    --remove the subtree in source hier for MOVE transaction
    IF p_hier_members_rec.transaction_type = 'MOVE' THEN
      --dbms_output.put_line('before remove the subtree in source hier');
      DELETE FROM RRS_SITE_GROUP_MEMBERS
      WHERE CHILD_MEMBER_ID IN (
        SELECT CHILD_MEMBER_ID
        FROM RRS_SITE_GROUP_MEMBERS
        START WITH CHILD_MEMBER_ID = v_child_id
        AND SITE_GROUP_ID = v_source_hier_id
        CONNECT BY PRIOR CHILD_MEMBER_ID = PARENT_MEMBER_ID
        AND SITE_GROUP_ID = v_source_hier_id)
      AND SITE_GROUP_ID = v_source_hier_id;
    END IF;

    --insert into members table
    --dbms_output.put_line('before insert into members table');
    FOR rec IN new_members_cursor LOOP
      --dbms_output.put_line(''||v_dest_hier_id||'/'||rec.PARENT_ID||'/'||rec.CHILD_ID);
      INSERT INTO RRS_SITE_GROUP_MEMBERS
			(
				SITE_GROUP_VERSION_ID,
				SITE_GROUP_ID,
				PARENT_MEMBER_ID,
				CHILD_MEMBER_ID,
				DELETED_FLAG,
				OBJECT_VERSION_NUMBER,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN,
				SEQUENCE_NUMBER
			)
      VALUES( v_dest_hier_version_id,
              v_dest_hier_id,
              rec.PARENT_ID,
              rec.CHILD_ID,
              'N',
              1,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              sysdate,
              fnd_global.user_id,
              rec.SEQUENCE_NUMBER);
    END LOOP;

  ELSE
    --RRS_INVALID_TYPE
    FND_MESSAGE.set_name('RRS', 'RRS_INVALID_TYPE');
    FND_MESSAGE.set_token('TYPE', p_hier_members_rec.transaction_type);
    FND_MSG_PUB.add;
    --dbms_output.put_line('invalid transaction type');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF FND_API.To_Boolean(p_commit) THEN
    COMMIT;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Update_Hierarchy_Fine;
    x_msg_count := FND_MSG_PUB.Count_Msg;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Update_Hierarchy_Fine;
    x_msg_data := G_PKG_NAME || '.Update_Hierarchy_Fine:' || x_msg_data;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    ROLLBACK TO Update_Hierarchy_Fine;
    x_msg_data := G_PKG_NAME || '.Update_Hierarchy_Fine:' || SQLERRM;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Update_Hierarchy_Fine;

-- Hierarchy and Hierarchy Association Validation API
procedure Validate_Hierarchy_Status(
        p_hier_id IN VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2
) IS

  v_hier_purpose_code VARCHAR2(30);

  CURSOR parent_child_cursor IS
  SELECT DECODE(RSV.SITE_ID, NULL, 'NODE', 'SITE') AS P_TYPE,
         RSGM.PARENT_MEMBER_ID AS P_ID,
         NVL(RSV.SITE_IDENTIFICATION_NUMBER, RSGNV.NODE_IDENTIFICATION_NUMBER) AS P_NUMBER,
         DECODE(RSV.SITE_ID, NULL, RSGNV.NODE_PURPOSE_CODE, RSU.SITE_USE_TYPE_CODE) AS P_PURPOSE_CODE,
         DECODE(RSV2.SITE_ID, NULL, 'NODE', 'SITE') AS C_TYPE,
         RSGM.CHILD_MEMBER_ID AS C_ID,
         NVL(RSV2.SITE_IDENTIFICATION_NUMBER, RSGNV2.NODE_IDENTIFICATION_NUMBER) AS C_NUMBER,
         DECODE(RSV2.SITE_ID, NULL, RSGNV2.NODE_PURPOSE_CODE, RSU2.SITE_USE_TYPE_CODE) AS C_PURPOSE_CODE,
         RSGM.SEQUENCE_NUMBER AS C_SEQ_NUMBER
  FROM RRS_SITE_GROUP_MEMBERS RSGM,
       RRS_SITE_GROUP_NODES_VL RSGNV,
       RRS_SITES_VL RSV, RRS_SITE_USES RSU,
       RRS_SITE_GROUP_NODES_VL RSGNV2,
       RRS_SITES_VL RSV2,
       RRS_SITE_USES RSU2
  WHERE RSGM.PARENT_MEMBER_ID = RSV.SITE_ID(+)
  AND RSGM.PARENT_MEMBER_ID = RSU.SITE_ID(+)
  AND NVL(RSU.IS_PRIMARY_FLAG, 'Y') = 'Y'
  AND RSGM.PARENT_MEMBER_ID = RSGNV.SITE_GROUP_NODE_ID(+)
  AND RSGM.CHILD_MEMBER_ID = RSV2.SITE_ID(+)
  AND RSGM.CHILD_MEMBER_ID = RSU2.SITE_ID(+)
  AND NVL(RSU2.IS_PRIMARY_FLAG, 'Y') = 'Y'
  AND RSGM.CHILD_MEMBER_ID = RSGNV2.SITE_GROUP_NODE_ID(+)
  START WITH PARENT_MEMBER_ID = -1
  AND SITE_GROUP_ID = p_hier_id
  CONNECT BY PRIOR CHILD_MEMBER_ID = PARENT_MEMBER_ID
  AND SITE_GROUP_ID = p_hier_id;

BEGIN

  --get hier purpose code
  BEGIN
    SELECT GROUP_PURPOSE_CODE
    INTO v_hier_purpose_code
    FROM RRS_SITE_GROUPS_VL RSGV
    WHERE RSGV.SITE_GROUP_ID = p_hier_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --RRS_NO_HIER_ID_FOUND
      FND_MESSAGE.set_name('RRS', 'RRS_NO_HIER_ID_FOUND');
      FND_MESSAGE.set_token('ID', p_hier_id);
      FND_MSG_PUB.add;
      --dbms_output.put_line('invalid dest hier id: '||p_hier_id);
      RAISE FND_API.G_EXC_ERROR;
  END;

  --RulesFwk
  --dbms_output.put_line('before RulesFwk');
  IF v_hier_purpose_code IS NOT NULL THEN

    --delete rows in RRS_SITE_GROUP_MEMBERS_TEMP
    DELETE FROM RRS_SITE_GROUP_MEMBERS_TEMP;

    FOR rec IN parent_child_cursor LOOP
      IF rec.P_ID <> -1 THEN
        --insert into members temp table
        --dbms_output.put_line('before insert into temp table 2');
        INSERT INTO RRS_SITE_GROUP_MEMBERS_TEMP
              (
                PARENT_TYPE,
                PARENT_ID,
                PARENT_NUMBER,
                PARENT_PURPOSE_CODE,
                CHILD_TYPE,
                CHILD_ID,
                CHILD_NUMBER,
                CHILD_PURPOSE_CODE,
                SEQUENCE_NUMBER,
                CHILD_NODE_NAME,
                CHILD_NODE_DESCRIPTION
              )
        VALUES( rec.P_TYPE,
                rec.P_ID,
                rec.P_NUMBER,
                rec.P_PURPOSE_CODE,
                rec.C_TYPE,
                rec.C_ID,
                rec.C_NUMBER,
                rec.C_PURPOSE_CODE,
                rec.C_SEQ_NUMBER,
                NULL,
                NULL
                );
      END IF;
    END LOOP;

    Validate_Rules_For_Members(
      p_hier_purpose_code => v_hier_purpose_code,
      x_return_status => x_return_status,
      x_msg_data => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_msg_count := FND_MSG_PUB.Count_Msg;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_msg_data := G_PKG_NAME || '.Validate_Hierarchy_Status:' || x_msg_data;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_msg_data := G_PKG_NAME || '.Validate_Hierarchy_Status:' || SQLERRM;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Hierarchy_Status;

procedure Validate_Hierarchy_Association(
        p_hier_id IN VARCHAR2,
        p_parent_id IN VARCHAR2,
        p_parent_object_type IN VARCHAR2,
        p_child_id IN VARCHAR2,
        p_child_object_type IN VARCHAR2,
        x_return_status OUT NOCOPY VARCHAR2,
        x_msg_count OUT NOCOPY NUMBER,
        x_msg_data OUT NOCOPY VARCHAR2
) IS

  v_parent_id_number VARCHAR2(30);
  v_parent_purpose_code VARCHAR2(30);
  v_child_id_number VARCHAR2(30);
  v_child_purpose_code VARCHAR2(30);
  v_hier_purpose_code VARCHAR2(30);
  v_hier_name VARCHAR2(30);
  v_count NUMBER;

BEGIN

  --get hier purpose code
  BEGIN
    SELECT GROUP_PURPOSE_CODE, NAME
    INTO v_hier_purpose_code, v_hier_name
    FROM RRS_SITE_GROUPS_VL RSGV
    WHERE RSGV.SITE_GROUP_ID = p_hier_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --RRS_NO_HIER_ID_FOUND
      FND_MESSAGE.set_name('RRS', 'RRS_NO_HIER_ID_FOUND');
      FND_MESSAGE.set_token('ID', p_hier_id);
      FND_MSG_PUB.add;
      --dbms_output.put_line('invalid dest hier id: '||p_hier_id);
      RAISE FND_API.G_EXC_ERROR;
  END;

  --get parent and child info
  IF p_parent_object_type = 'SITE' THEN
    BEGIN
      SELECT RSV.SITE_IDENTIFICATION_NUMBER, RSU.SITE_USE_TYPE_CODE
      INTO v_parent_id_number, v_parent_purpose_code
      FROM RRS_SITES_VL RSV, RRS_SITE_USES RSU
      WHERE RSV.SITE_ID = p_parent_id
      AND RSV.SITE_ID = RSU.SITE_ID(+)
      AND RSU.IS_PRIMARY_FLAG(+) = 'Y';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --RRS_NO_SITE_FOUND
        FND_MESSAGE.set_name('RRS', 'RRS_NO_SITE_FOUND');
        FND_MESSAGE.set_token('SITE_ID_NUM', p_parent_id);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
    END;
  ELSIF p_parent_object_type = 'NODE' THEN
    BEGIN
      SELECT NODE_IDENTIFICATION_NUMBER, NODE_PURPOSE_CODE
      INTO v_parent_id_number, v_parent_purpose_code
      FROM RRS_SITE_GROUP_NODES_VL
      WHERE SITE_GROUP_NODE_ID = p_parent_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --RRS_NO_NODE_FOUND
        FND_MESSAGE.set_name('RRS', 'RRS_NO_NODE_FOUND');
        FND_MESSAGE.set_token('NODE_ID_NUM', p_parent_id);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
    END;
  ELSE
    --RRS_INVALID_TYPE
    FND_MESSAGE.set_name('RRS', 'RRS_INVALID_TYPE');
    FND_MESSAGE.set_token('TYPE', p_parent_object_type);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  IF p_child_object_type = 'SITE' THEN
    BEGIN
      SELECT RSV.SITE_IDENTIFICATION_NUMBER, RSU.SITE_USE_TYPE_CODE
      INTO v_child_id_number, v_child_purpose_code
      FROM RRS_SITES_VL RSV, RRS_SITE_USES RSU
      WHERE RSV.SITE_ID = p_child_id
      AND RSV.SITE_ID = RSU.SITE_ID(+)
      AND RSU.IS_PRIMARY_FLAG(+) = 'Y';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --RRS_NO_SITE_FOUND
        FND_MESSAGE.set_name('RRS', 'RRS_NO_SITE_FOUND');
        FND_MESSAGE.set_token('SITE_ID_NUM', p_child_id);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
    END;
  ELSIF p_child_object_type = 'NODE' THEN
    BEGIN
      SELECT NODE_IDENTIFICATION_NUMBER, NODE_PURPOSE_CODE
      INTO v_child_id_number, v_child_purpose_code
      FROM RRS_SITE_GROUP_NODES_VL
      WHERE SITE_GROUP_NODE_ID = p_child_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        --RRS_NO_NODE_FOUND
        FND_MESSAGE.set_name('RRS', 'RRS_NO_NODE_FOUND');
        FND_MESSAGE.set_token('NODE_ID_NUM', p_child_id);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
    END;
  ELSE
    --RRS_INVALID_TYPE
    FND_MESSAGE.set_name('RRS', 'RRS_INVALID_TYPE');
    FND_MESSAGE.set_token('TYPE', p_child_object_type);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --child id should not appear in the dest hier
  SELECT COUNT(*)
  INTO v_count
  FROM RRS_SITE_GROUP_MEMBERS
  WHERE CHILD_MEMBER_ID = p_child_id
  AND SITE_GROUP_ID = p_hier_id;
  IF v_count <> 0 THEN
    --RRS_HIER_CHILD_EXISTS
    FND_MESSAGE.set_name('RRS', 'RRS_HIER_CHILD_EXISTS');
    FND_MESSAGE.set_token('NUM', v_child_id_number);
    FND_MESSAGE.set_token('TYPE', p_child_object_type);
    FND_MESSAGE.set_token('HIERARCHY_NAME', v_hier_name);
    FND_MSG_PUB.add;
    --dbms_output.put_line('Child already exists in the destination hierarchy: '||v_child_id_number);
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --dbms_output.put_line(v_hier_purpose_code||' '||v_parent_purpose_code||' '||v_child_purpose_code);

  --RulesFwk
  --dbms_output.put_line('before RulesFwk');
  IF v_hier_purpose_code IS NOT NULL THEN

    Validate_Rules_For_Child(
      p_hier_purpose_code => v_hier_purpose_code,
      p_parent_id_number => v_parent_id_number,
      p_parent_object_type => p_parent_object_type,
      p_parent_purpose_code => v_parent_purpose_code,
      p_child_id_number => v_child_id_number,
      p_child_object_type => p_child_object_type,
      p_child_purpose_code => v_child_purpose_code,
      x_return_status => x_return_status,
      x_msg_data => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_msg_count := FND_MSG_PUB.Count_Msg;
    x_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_msg_data := G_PKG_NAME || '.Validate_Hierarchy_Association:' || x_msg_data;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    x_msg_data := G_PKG_NAME || '.Validate_Hierarchy_Association:' || SQLERRM;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Hierarchy_Association;

-------Testing procedures------
/*
procedure Update_Hierarchy_Header_Test IS
  v_name VARCHAR2(30) := 'R0001';
  v_new_name VARCHAR2(30) := 'R0001';
  v_desc VARCHAR2(30) := 'test desc';
  v_purp VARCHAR2(30) := 'OPER';
  v_sd DATE := TO_DATE('jan 23 2009', 'MON DD YYYY');
  v_ed DATE := TO_DATE('DEC 23 2009', 'MON DD YYYY');
  x_return_status VARCHAR2(30);
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(30);
BEGIN

  RRS_HIERARCHY_CRUD_PKG.Update_Hierarchy_Header(
        p_name => v_name,
        --p_new_name => v_new_name,
        p_description => v_desc,
        --p_purpose_code => v_purp,
        p_start_date => v_sd,
        --p_end_date => v_ed,
        p_nullify_flag => 'T',
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
        );
  --dbms_output.put_line('update hierarchy header: ' || x_return_status);
END Update_Hierarchy_Header_Test;

procedure Update_Hierarchy_Node_Test IS
  v_number VARCHAR2(30) := 'temp_11040';
  v_name VARCHAR2(30) := 'tempNode@';
  v_desc VARCHAR2(30) := 'test node desc';
  v_purp VARCHAR2(30) := 'BRKPNT';
  x_return_status VARCHAR2(30);
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(30);
BEGIN

  RRS_HIERARCHY_CRUD_PKG.Update_Hierarchy_Node(
        p_number => v_number,
        --p_name => v_name,
        p_description => v_desc,
        --p_purpose_code => v_purp
        --p_nullify_flag => 'T'
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
        );
END Update_Hierarchy_Node_Test;

procedure Create_Hierarchy_Node_Test IS
  v_number VARCHAR2(30) := 'CREATE_TEST';
  v_name VARCHAR2(30) := 'newlyCreatedNode';
  v_desc VARCHAR2(30) := 'test node desc';
  v_purp VARCHAR2(30) := 'BRKPNT';
  x_return_status VARCHAR2(30);
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(30);
BEGIN

  RRS_HIERARCHY_CRUD_PKG.Create_Hierarchy_Node(
        p_number => v_number,
        p_name => v_name,
        p_description => v_desc,
        p_purpose_code => v_purp,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
        );
  --dbms_output.put_line('msg count: ' || x_msg_count);
END Create_Hierarchy_Node_Test;

procedure Create_Hierarchy_Coarse_Test IS
  v_name VARCHAR2(30) := 'R0005';
  v_desc VARCHAR2(30) := 'test desc';
  v_purp VARCHAR2(30) := 'OPER';
  v_sd DATE := TO_DATE('jan 23 2009', 'MON DD YYYY');
  v_ed DATE := TO_DATE('DEC 23 2009', 'MON DD YYYY');
  v_tab RRS_HIER_MEMBERS_COARSE_TAB;
  x_return_status VARCHAR2(30);
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(30);
BEGIN

  v_tab := RRS_HIER_MEMBERS_COARSE_TAB();
  v_tab.EXTEND();
  v_tab(1) := RRS_HIER_MEMBERS_COARSE_REC('NONE', NULL, 'NONE', 'NODE', NULL, 'ROOT_R0005', 0, 'R0005', NULL, 'ROOT');
  v_tab.EXTEND();
  v_tab(2) := RRS_HIER_MEMBERS_COARSE_REC('NODE', NULL, 'ROOT_R0005', 'SITE', 10141, NULL, 10, NULL, NULL, NULL);
  v_tab.EXTEND();
  v_tab(3) := RRS_HIER_MEMBERS_COARSE_REC('NODE', NULL, 'ROOT_R0005', 'NODE', NULL, 'NEW_NODE_R5', 20, 'new node R5', NULL, 'BRKPNT');
  v_tab.EXTEND();
  v_tab(4) := RRS_HIER_MEMBERS_COARSE_REC('NODE', NULL, 'NEW_NODE_R5', 'NODE', 10005, NULL, 10, 'tempNODE', 'test description', 'BRKPNT');
  v_tab.EXTEND();
  v_tab(5) := RRS_HIER_MEMBERS_COARSE_REC('NODE', NULL, 'NEW_NODE_R5', 'SITE', NULL, 'MBOX0001', 20, NULL, NULL, NULL);
  --v_tab.EXTEND();
  --v_tab(6) := RRS_HIER_MEMBERS_COARSE_REC('NODE', NULL, 'temp_11040', 'SITE', NULL, 'MBOX980', 10, NULL, NULL, NULL);

  RRS_HIERARCHY_CRUD_PKG.Create_Hierarchy_Coarse(
        p_hier_name => v_name,
        p_hier_description => v_desc,
        --p_hier_purpose_code => v_purp,
        p_hier_start_date => v_sd,
        p_hier_end_date => v_ed,
        p_hier_members_tab => v_tab,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
        );
  --dbms_output.put_line('create hierarchy coarse: ' || x_return_status);
END Create_Hierarchy_Coarse_Test;

procedure Update_Hierarchy_Coarse_Test IS
  v_name VARCHAR2(30) := 'Unit Hierarchy';
  v_new_name VARCHAR2(30) := 'R0004';
  v_desc VARCHAR2(30) := 'TEST ROUTE';
  v_purp VARCHAR2(30) := 'OPER2';
  v_sd DATE := TO_DATE('jan 24 2009', 'MON DD YYYY');
  v_ed DATE := TO_DATE('DEC 23 2009', 'MON DD YYYY');
  v_tab RRS_HIER_MEMBERS_COARSE_TAB;
  x_return_status VARCHAR2(30);
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(30);
BEGIN

  v_tab := RRS_HIER_MEMBERS_COARSE_TAB();

  v_tab.EXTEND();
  v_tab(1) := RRS_HIER_MEMBERS_COARSE_REC('NONE', -1, NULL, 'NODE', 10003, NULL, 0, NULL, NULL, 'ROOT');
  v_tab.EXTEND();
  v_tab(2) := RRS_HIER_MEMBERS_COARSE_REC('NODE', 10003, NULL, 'NODE', 10006, NULL, 0, NULL, NULL, NULL);
  v_tab.EXTEND();
  v_tab(3) := RRS_HIER_MEMBERS_COARSE_REC('NODE', 10006, NULL, 'SITE', 10002, NULL, 0, NULL, NULL, NULL);
  v_tab.EXTEND();
  v_tab(4) := RRS_HIER_MEMBERS_COARSE_REC('NODE', 10003, NULL, 'NODE', 10004, NULL, 0, NULL, NULL, NULL);
  v_tab.EXTEND();
  v_tab(5) := RRS_HIER_MEMBERS_COARSE_REC('NODE', 10004, NULL, 'SITE', 10000, NULL, 0, NULL, NULL, NULL);
  v_tab.EXTEND();
  v_tab(6) := RRS_HIER_MEMBERS_COARSE_REC('NODE', 10003, NULL, 'NODE', 10005, NULL, 0, NULL, NULL, NULL);

  RRS_HIERARCHY_CRUD_PKG.Update_Hierarchy_Coarse(
        p_hier_name => v_name,
        --p_hier_new_name => v_new_name,
        --p_hier_description => v_desc,
        --p_hier_purpose_code => v_purp,
        --p_hier_start_date => v_sd,
        --p_nullify_flag => 'T',
        --p_hier_end_date => v_ed,
        p_hier_members_tab => v_tab,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
        );
  --dbms_output.put_line('update hierarchy coarse: ' || x_return_status);
END Update_Hierarchy_Coarse_Test;

procedure Update_Hierarchy_Fine_Test IS
  x_return_status VARCHAR2(30);
  v_rec RRS_HIER_MEMBERS_FINE_REC;
  x_msg_count NUMBER;
  x_msg_data VARCHAR2(30);
BEGIN

  v_rec := RRS_HIER_MEMBERS_FINE_REC('ADD', NULL, 'Unit Hierarchy', NULL, NULL, 'NODE', '10004', 'SITE', 'NH_Template_Site_1', 10);
  --v_rec := RRS_HIER_MEMBERS_FINE_REC('ADD', NULL, 'R0001', NULL, NULL, 'NODE', 'NEW_NODE_R1', 'NODE', '10004', 10);
  --v_rec := RRS_HIER_MEMBERS_FINE_REC('REMOVE', NULL, 'R0001', NULL, NULL, NULL, NULL, 'SITE', 'MBOX0001', 10);
  --v_rec := RRS_HIER_MEMBERS_FINE_REC('REMOVE', NULL, 'R0001', NULL, NULL, NULL, NULL, 'NODE', '10005', 10);
  --v_rec := RRS_HIER_MEMBERS_FINE_REC('COPY', 'R0002', 'R0001', NULL, NULL, 'SITE', 'NH_SITE_1','SITE','MBOX0001', 10);
  --v_rec := RRS_HIER_MEMBERS_FINE_REC('MOVE', 'R0002', 'R0001', NULL, NULL, 'SITE', 'NH_SITE_1','NODE','NEW_NODE_R2', 10);
  --v_rec := RRS_HIER_MEMBERS_FINE_REC('COPY', 'R0001', 'R0002', NULL, NULL, 'SITE', 'MBOX0001','NODE','NEW_NODE_R1', 10);
  Update_Hierarchy_Fine(
        p_hier_members_rec => v_rec,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data
  );
  --dbms_output.put_line('update hierarchy fine: ' || x_return_status);
END Update_Hierarchy_Fine_Test;
*/

END RRS_HIERARCHY_CRUD_PKG;



/
