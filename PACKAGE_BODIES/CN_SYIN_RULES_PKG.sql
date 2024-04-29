--------------------------------------------------------
--  DDL for Package Body CN_SYIN_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_SYIN_RULES_PKG" AS
-- $Header: cnsyinfb.pls 120.6 2006/01/13 03:57:15 hanaraya noship $


-- Procedure Name
--   Populate_Fields
-- Purpose

-- History
--   01/26/94         Tony Lower              Created
--   08-08-95         Amy Erickson            Updated
--   08-30-95         Amy Erickson            Updated

PROCEDURE Populate_Fields (x_revenue_class_id   IN OUT NOCOPY number,
                           x_revenue_class_name IN OUT NOCOPY varchar2,
			   x_org_id IN NUMBER) IS

  BEGIN

    IF (x_revenue_class_id IS NOT NULL) THEN
      SELECT name
        INTO x_revenue_class_name
        FROM cn_revenue_classes
       WHERE revenue_class_id = x_revenue_class_id and org_id=x_org_id;
    ELSE
       x_revenue_class_name := NULL ;
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       x_revenue_class_id   := NULL ;
       x_revenue_class_name := NULL ;

  END Populate_fields;




 PROCEDURE Insert_Row (x_rule_id             number,
			x_name                varchar2,
			x_ruleset_id          number,
			x_revenue_class_id    number,
			x_expense_ccid        NUMBER,
			x_liability_ccid      NUMBER,
			x_parent_rule_id      number,
		        x_sequence_number     number,
                        x_org_id number) IS
	l_rowid ROWID;
  BEGIN
     insert_row_into_cn_rules_only(
				   x_rowid   => l_rowid,
				   x_rule_id => x_rule_id,
				   x_name    => x_name,
				   x_ruleset_id => x_ruleset_id,
				   x_revenue_class_id => x_revenue_class_id,
				   x_expense_ccid => x_expense_ccid,
				   x_liability_ccid => x_liability_ccid,
                                   x_org_id =>x_org_id);

      INSERT INTO cn_rules_hierarchy
                (rule_id, parent_rule_id, sequence_number, ruleset_id,org_id)
      VALUES (x_rule_id, x_parent_rule_id, x_sequence_number, x_ruleset_id, x_org_id);

      unsync_ruleset(x_ruleset_id,x_org_id);
    END Insert_Row;


    procedure insert_row_into_cn_rules_only
      (
       X_ROWID in out nocopy VARCHAR2,
       X_RULE_ID in NUMBER,
       X_RULESET_ID in NUMBER,
       X_PACKAGE_ID in NUMBER,
       X_REVENUE_CLASS_ID in NUMBER,
       x_expense_ccid IN NUMBER,
       x_liability_ccid IN NUMBER,
       X_NAME in VARCHAR2,
       X_CREATION_DATE in DATE,
       X_CREATED_BY in NUMBER,
       X_LAST_UPDATE_DATE in DATE,
       X_LAST_UPDATED_BY in NUMBER,
       X_LAST_UPDATE_LOGIN in NUMBER,
       X_ORG_ID in number
       ) IS



  L_RULE_ID  NUMBER;
  L_RULESET_ID  NUMBER;
  L_PACKAGE_ID  NUMBER;
  L_REVENUE_CLASS_ID  NUMBER;
  l_expense_ccid NUMBER;
  l_liability_ccid NUMBER;
  L_NAME  cn_rules.name%TYPE;
  L_CREATION_DATE  DATE;
  L_CREATED_BY  NUMBER;
  L_LAST_UPDATE_DATE  DATE;
  L_LAST_UPDATED_BY  NUMBER;
  L_LAST_UPDATE_LOGIN  NUMBER;
  L_ORG_ID NUMBER;

BEGIN

  SELECT Decode(x_RULE_ID, FND_API.G_MISS_NUM, NULL,
		    Ltrim(Rtrim(x_RULE_ID)))
    INTO l_RULE_ID FROM sys.dual;

  SELECT Decode(x_RULESET_ID, FND_API.G_MISS_NUM, NULL,
		    Ltrim(Rtrim(x_RULESET_ID)))
    INTO l_RULESET_ID FROM sys.dual;

  SELECT Decode(x_PACKAGE_ID, FND_API.G_MISS_NUM, NULL,
		    Ltrim(Rtrim(x_PACKAGE_ID)))
    INTO l_PACKAGE_ID FROM sys.dual;

  SELECT Decode(x_REVENUE_CLASS_ID, FND_API.G_MISS_NUM, NULL,
		    Ltrim(Rtrim(x_REVENUE_CLASS_ID)))
    INTO l_REVENUE_CLASS_ID FROM sys.dual;

  SELECT Decode(x_expense_ccid, FND_API.G_MISS_NUM, NULL,
		    Ltrim(Rtrim(x_expense_ccid)))
    INTO l_expense_ccid FROM sys.dual;

  SELECT Decode(x_liability_ccid, FND_API.G_MISS_NUM, NULL,
		    Ltrim(Rtrim(x_liability_ccid)))
    INTO l_liability_ccid FROM sys.dual;

  SELECT Decode(x_NAME, FND_API.G_MISS_CHAR, NULL,
		    Ltrim(Rtrim(x_NAME)))
    INTO l_NAME FROM sys.dual;

  SELECT Decode(x_CREATION_DATE, FND_API.G_MISS_DATE, NULL,
		    Ltrim(Rtrim(x_CREATION_DATE)))
    INTO l_CREATION_DATE FROM sys.dual;

  SELECT Decode(x_CREATED_BY, FND_API.G_MISS_NUM, NULL,
		    Ltrim(Rtrim(x_CREATED_BY)))
    INTO l_CREATED_BY FROM sys.dual;

  SELECT Decode(x_LAST_UPDATE_DATE, FND_API.G_MISS_DATE, NULL,
		    Ltrim(Rtrim(x_LAST_UPDATE_DATE)))
    INTO l_LAST_UPDATE_DATE FROM sys.dual;

  SELECT Decode(x_LAST_UPDATED_BY, FND_API.G_MISS_NUM, NULL,
		    Ltrim(Rtrim(x_LAST_UPDATED_BY)))
    INTO l_LAST_UPDATED_BY FROM sys.dual;

  SELECT Decode(x_LAST_UPDATE_LOGIN, FND_API.G_MISS_NUM, NULL,
		    Ltrim(Rtrim(x_LAST_UPDATE_LOGIN)))
    INTO l_LAST_UPDATE_LOGIN FROM sys.dual;

  SELECT Decode(x_ORG_ID, FND_API.G_MISS_NUM, NULL,
		    Ltrim(Rtrim(x_ORG_ID)))
    INTO l_ORG_ID FROM sys.dual;

  insert into CN_RULES_ALL_B
    (
     PACKAGE_ID,
     RULE_ID,
     RULESET_ID,
     REVENUE_CLASS_ID,
     expense_ccid,
     liability_ccid,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     LAST_UPDATE_LOGIN,
     ORG_ID
     ) values
    (
     L_PACKAGE_ID,
     L_RULE_ID,
     L_RULESET_ID,
     L_REVENUE_CLASS_ID,
     l_expense_ccid,
     l_liability_ccid,
     L_CREATION_DATE,
     L_CREATED_BY,
     L_LAST_UPDATE_DATE,
     L_LAST_UPDATED_BY,
     L_LAST_UPDATE_LOGIN,
     L_ORG_ID
     );

  insert into CN_RULES_ALL_TL (
    NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    RULESET_ID,
    RULE_ID,
    LANGUAGE,
    SOURCE_LANG,
    ORG_ID
  ) select
    L_NAME,
    L_LAST_UPDATE_DATE,
    L_LAST_UPDATED_BY,
    L_LAST_UPDATE_LOGIN,
    L_CREATION_DATE,
    L_CREATED_BY,
    L_RULESET_ID,
    L_RULE_ID,
    L.LANGUAGE_CODE,
    userenv('LANG'),
    L_ORG_ID
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from CN_RULES_ALL_TL T
    where T.RULE_ID = L_RULE_ID
    and T.RULESET_ID = L_RULESET_ID --RC 06-APR-99 Added code
    and T.LANGUAGE = L.language_code AND
	T.ORG_ID=L_ORG_ID);


end INSERT_ROW_into_cn_rules_only;


-- Procedure Name
--   unsync_ruleset
-- History
--   17-Feb-99 Renu Chintalapati    Created

PROCEDURE unsync_ruleset (x_ruleset_id number, x_org_id number) IS
  BEGIN
    UPDATE cn_rulesets_all_b
    SET    ruleset_status = 'UNSYNC'
    WHERE  ruleset_id = x_ruleset_id
    and ORG_ID=  x_org_id  ;
  END unsync_ruleset;



procedure UPDATE_ROW
  (
  X_RULE_ID in NUMBER,
  X_RULESET_ID in NUMBER,
  X_PACKAGE_ID in NUMBER,
   X_REVENUE_CLASS_ID in NUMBER,
   x_expense_ccid IN NUMBER,
   x_liability_ccid IN NUMBER,
  X_NAME in VARCHAR2,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER,
  X_ORG_ID IN NUMBER,
  X_OBJECT_VERSION_NO IN OUT NOCOPY NUMBER
) is
begin
  X_OBJECT_VERSION_NO:=X_OBJECT_VERSION_NO+1;
  update CN_RULES_ALL_B set
    PACKAGE_ID = X_PACKAGE_ID,
    REVENUE_CLASS_ID = X_REVENUE_CLASS_ID,
    expense_ccid = x_expense_ccid,
    liability_ccid = x_liability_ccid,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    OBJECT_VERSION_NUMBER=X_OBJECT_VERSION_NO
  where RULE_ID = X_RULE_ID
  and RULESET_ID = x_ruleset_id  AND
	ORG_ID=X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  update CN_RULES_ALL_TL set
    NAME = X_NAME,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where RULE_ID = X_RULE_ID
  and RULESET_ID = X_RULESET_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG) AND
  ORG_ID=X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


procedure DELETE_ROW (X_RULE_ID in NUMBER,
                      X_RULESET_ID in NUMBER,
                      X_ORG_ID IN NUMBER) IS --RC 2/25/99 Added ruleset id
      Cursor Cascade IS (SELECT rule_id
                           FROM cn_rules_hierarchy
                          WHERE parent_rule_id = x_rule_id
                            AND ruleset_id = x_ruleset_id AND
                            ORG_ID=X_ORG_ID);
BEGIN

  DELETE cn_attribute_rules
   WHERE rule_id = x_rule_id
     AND ruleset_id = x_ruleset_id ;

  DELETE cn_rules_hierarchy
   WHERE rule_id = x_rule_id
     AND ruleset_id = x_ruleset_id;

  delete from CN_RULES_ALL_TL
  where RULE_ID = X_RULE_ID
    and ruleset_id = x_ruleset_id
  and	ORG_ID=X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from CN_RULES_ALL_B
  where RULE_ID = X_RULE_ID
   and ruleset_id = x_ruleset_id AND
  ORG_ID=X_ORG_ID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  unsync_ruleset(x_ruleset_id,X_ORG_ID);

  FOR C in Cascade LOOP
      Delete_Row(C.rule_id, x_ruleset_id,X_ORG_ID);
  END Loop;

  DELETE cn_rules_hierarchy
    WHERE parent_rule_id = x_rule_id
      AND ruleset_id = x_ruleset_id AND
      ORG_ID=X_ORG_ID;

end DELETE_ROW;



procedure ADD_LANGUAGE
is
begin
  delete from CN_RULES_ALL_TL T
  where not exists
    (select NULL
    from CN_RULES_ALL_B B
    where B.RULE_ID = T.RULE_ID
    and B.RULESET_ID = T.ruleset_id
    and   B.ORG_ID= T.ORG_ID
           );

  update CN_RULES_ALL_TL T set (
      NAME
    ) = (select
      B.NAME
    from CN_RULES_ALL_TL B
    where B.RULE_ID = T.RULE_ID
    and B.RULESET_ID = T.RULESET_ID
    and B.LANGUAGE = T.source_lang
    and    B.ORG_ID= T.ORG_ID)
  where (
      T.RULE_ID,
      T.RULESET_ID,
      T.LANGUAGE
  ) in (select
      SUBT.RULE_ID,
      SUBT.RULESET_ID,
      SUBT.LANGUAGE
    from CN_RULES_ALL_TL SUBB, CN_RULES_ALL_TL SUBT
    where SUBB.RULE_ID = SUBT.RULE_ID
    and SUBB.RULESET_ID = SUBT.RULESET_ID
    and SUBB.LANGUAGE = SUBT.source_lang
    and   SUBB.ORG_ID=SUBT.ORG_ID

    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
	 ));

  insert into CN_RULES_ALL_TL (
    NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATION_DATE,
    CREATED_BY,
    RULESET_ID,
    RULE_ID,
    LANGUAGE,
    SOURCE_LANG,
    ORG_ID
  ) select
    B.NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.RULESET_ID,
    B.RULE_ID,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG,
    B.ORG_ID
  from CN_RULES_ALL_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from CN_RULES_ALL_TL T
    where T.RULE_ID = B.RULE_ID
    and T.RULESET_ID = B.RULESET_ID
    and T.LANGUAGE = L.language_code AND
    T.ORG_ID=B.ORG_ID);
end ADD_LANGUAGE;





--------------------------------------------------------------------------+
-- Procedure Name:	download				        --+
-- Purpose								--+
-- This procedure is used to download the required data to the inter-   --+
-- face table for export to a different data base                       --+
--------------------------------------------------------------------------+
  PROCEDURE download
    (errbuf 	OUT NOCOPY VARCHAR2,
     retcode	OUT NOCOPY NUMBER) IS

  TYPE cnclrl_api_type IS RECORD
  (clrl_api_id                NUMBER,
   ruleset_name               cn_clrl_api_v.ruleset_name%TYPE,
   start_date                 cn_clrl_api_v.start_date%TYPE,
   end_date                   cn_clrl_api_v.end_date%TYPE,
   rule_name                  cn_clrl_api_v.rule_name%TYPE,
   parent_rule_name           cn_clrl_api_v.parent_rule_name%TYPE,
   revenue_class_name         cn_clrl_api_v.revenue_class_name%TYPE,
   object_name                cn_clrl_api_v.object_name%TYPE,
   not_flag                   cn_clrl_api_v.not_flag%TYPE,
   value_1                    cn_clrl_api_v.value_1%TYPE,
   value_2                    cn_clrl_api_v.value_2%TYPE,
   data_flag                  cn_clrl_api_v.data_flag%TYPE
   );

  TYPE cnclrl_tbl_type IS TABLE OF cnclrl_api_type INDEX BY BINARY_INTEGER;
  cnclrl_tbl cnclrl_tbl_type;

  CURSOR cnclrl_cur IS
     SELECT *
       FROM cn_clrl_api_v;

  l_proc_audit_id NUMBER;
  j               NUMBER;
  l_api_id        NUMBER;

BEGIN

 /*  retcode := 0;
   -- Initial message list
   FND_MSG_PUB.initialize;

   cn_message_pkg.begin_batch
     ( x_process_type            => 'CLS',
       x_process_audit_id        => l_proc_audit_id,
       x_parent_proc_audit_id    => l_proc_audit_id,
       x_request_id              => NULL);
   cn_message_pkg.debug('***************************************************');
   cn_message_pkg.debug('Processing Classification Rule set');

   j := 0;

   FOR i IN cnclrl_cur
     LOOP
        SELECT cn_clrl_api_s.NEXTVAL
	  INTO l_api_id
	  FROM dual;

	cnclrl_tbl(j).clrl_api_id := l_api_id;
	cnclrl_tbl(j).ruleset_name := i.ruleset_name;
	cnclrl_tbl(j).start_date := i.start_date;
	cnclrl_tbl(j).end_date := i.end_date;
	cnclrl_tbl(j).rule_name := i.rule_name;
	cnclrl_tbl(j).parent_rule_name := i.parent_rule_name;
	cnclrl_tbl(j).revenue_class_name := i.revenue_class_name;
	cnclrl_tbl(j).object_name := i.object_name ;
	cnclrl_tbl(j).not_flag := i.not_flag ;
	cnclrl_tbl(j).value_1 := i.value_1;
	cnclrl_tbl(j).value_2 := i.value_2;
	cnclrl_tbl(j).data_flag := i.data_flag;
	j := j + 1;
     END LOOP;

     for i IN cnclrl_tbl.first .. cnclrl_tbl.last loop
       INSERT INTO cn_clrl_api
       (clrl_api_id,
	ruleset_name,
	start_date,
	end_date,
	rule_name,
	parent_rule_name,
	revenue_class_name,
	object_name,
	not_flag,
	value_1,
	value_2,
	data_flag)
       VALUES
       (cnclrl_tbl(i).clrl_api_id,
	cnclrl_tbl(i).ruleset_name,
	cnclrl_tbl(i).start_date,
	cnclrl_tbl(i).end_date,
	cnclrl_tbl(i).rule_name,
	cnclrl_tbl(i).parent_rule_name,
	cnclrl_tbl(i).revenue_class_name,
	cnclrl_tbl(i).object_name,
	cnclrl_tbl(i).not_flag,
	cnclrl_tbl(i).value_1,
	cnclrl_tbl(i).value_2,
	cnclrl_tbl(i).data_flag);
      END LOOP;

   cn_message_pkg.end_batch(l_proc_audit_id);

EXCEPTION
   WHEN OTHERS THEN
      cn_message_pkg.debug('Unhandled Exception');
      cn_message_pkg.end_batch(l_proc_audit_id);
      retcode := 2;
      errbuf := SQLCODE || ' ' || Sqlerrm;
      */
      null;
END download;

--------------------------------------------------------------------------+
-- Procedure Name:	upload				                --+
-- Purpose								--+
-- This procedure is used to upload the required data from the inter-   --+
-- face table to the appropriate tables in the database                 --+
--------------------------------------------------------------------------+
PROCEDURE upload(errbuf 	OUT NOCOPY VARCHAR2,
		 retcode	OUT NOCOPY NUMBER) IS

      CURSOR rulesets
	IS SELECT ruleset_name, start_date, end_date
	  FROM cn_clrl_api
	  WHERE loading_status <> 'CN_INSERTED' OR loading_status IS NULL
	    GROUP BY ruleset_name, start_date, end_date;

      CURSOR top_level_rules
	    (p_ruleset_name cn_clrl_api.ruleset_name%TYPE,
	     p_start_date   cn_clrl_api.start_date%TYPE,
	     p_end_date     cn_clrl_api.end_date%TYPE)
	    IS SELECT rule_name
	  FROM cn_clrl_api cna1
	  WHERE ruleset_name = p_ruleset_name
	  AND (loading_status <> 'CN_INSERTED' OR loading_status IS NULL)
	    AND parent_rule_name NOT IN
	    (SELECT rule_name
	     FROM cn_clrl_api
	     WHERE ruleset_name = p_ruleset_name
	     AND start_date = p_start_date
	     AND end_date = p_end_date
	     AND (loading_status <> 'CN_INSERTED' OR loading_status IS NULL) );

      CURSOR rules
	(p_ruleset_name cn_clrl_api.ruleset_name%TYPE,
	 p_start_date   cn_clrl_api.start_date%TYPE,
	 p_end_date     cn_clrl_api.end_date%TYPE,
	 p_start_rule_name cn_clrl_api.rule_name%TYPE)IS
	    SELECT rule_name, parent_rule_name, revenue_class_name
	      FROM (SELECT rule_name, parent_rule_name, revenue_class_name
		    FROM cn_clrl_api
		    WHERE ruleset_name = p_ruleset_name
		    AND start_date = p_start_date
		    AND end_date = p_end_date
		    AND (loading_status <> 'CN_INSERTED' OR loading_status IS NULL)
		    GROUP BY rule_name, parent_rule_name, revenue_class_name)
		      CONNECT BY PRIOR rule_name = parent_rule_name
		      START WITH rule_name = p_start_rule_name;

      CURSOR rule_attributes
	(p_ruleset_name cn_clrl_api.ruleset_name%TYPE,
	 p_start_date cn_clrl_api.start_date%TYPE,
	 p_end_date cn_clrl_api.end_date%TYPE,
	 p_rule_name    cn_clrl_api.rule_name%TYPE,
	 p_parent_rule_name cn_clrl_api.parent_rule_name%TYPE) IS
	    SELECT attribute_rule_name, not_flag,
	      value_1, value_2, data_flag, object_name
	      FROM cn_clrl_api
	      WHERE loading_status <> 'CN_INSERTED' OR loading_status IS NULL
		AND ruleset_name = p_ruleset_name
		AND rule_name = p_rule_name
		AND parent_rule_name = p_parent_rule_name;

	      l_api_version                 CONSTANT NUMBER := 1.0;
	      l_msg_count                   NUMBER;
	      l_msg_data                    VARCHAR2(2000);
	      l_return_status               VARCHAR2(1);
	      l_loading_status              VARCHAR2(30);
	      l_loaded_counter              NUMBER := 0;
	      l_total_counter               NUMBER := 0;
	      l_proc_audit_id               NUMBER(15);
	      l_ruleset_rec                 cn_ruleset_pub.ruleset_rec_type;
	      l_rule_rec                    cn_rule_pub.rule_rec_type;
	      l_ruleattribute_rec           cn_ruleattribute_pub.ruleattribute_rec_type;
	      l_count                       NUMBER;

BEGIN
/*
   retcode := 0;
   -- Initial message list
   FND_MSG_PUB.initialize;

   cn_message_pkg.begin_batch

     ( x_process_type            => 'CLS',
       x_process_audit_id        => l_proc_audit_id,
       x_parent_proc_audit_id    => l_proc_audit_id,
       x_request_id              => NULL
       );
   cn_message_pkg.debug('***************************************************');
   cn_message_pkg.debug('Processing Classification Rule set');

   FOR i IN rulesets
     LOOP
	SELECT COUNT(1)
	  INTO l_count
	  FROM cn_rulesets
	  WHERE name = i.ruleset_name
	  AND start_date = i.start_date
	  AND end_date = i.end_date;

	IF l_count = 0
	  THEN
	   l_ruleset_rec.ruleset_name := i.ruleset_name;
	   l_ruleset_rec.start_date   := i.start_date;
	   l_ruleset_rec.end_date     := i.end_date;


	   -- Need to refactor public package
	   cn_ruleset_pub.create_ruleset
	     ( p_api_version      => 1.0,
	       p_init_msg_list    => fnd_api.g_true,
	       p_commit           => FND_API.G_FALSE,
	       p_validation_level => FND_API.G_VALID_LEVEL_FULL,
	       x_return_status    => l_return_status,
	       x_msg_count        => l_msg_count,
	       x_msg_data         => l_msg_data,
	       x_loading_status   => l_loading_status,
	       p_ruleset_rec      => l_ruleset_rec);


	   IF(l_return_status = FND_API.g_ret_sts_success) THEN

	      UPDATE cn_clrl_api
		SET loading_status = 'CN_RULESET_INSERTED'
		WHERE ruleset_name = i.ruleset_name
		AND start_date = i.start_date
		AND end_date = i.end_date
		AND (loading_status <> 'CN_INSERTED' OR loading_status IS NULL);

	    ELSE
	      -- retcode 0 = success, 1 = warning, 2 = error
	      retcode := 2;
	      cn_message_pkg.debug('Error for rulesets '||i.ruleset_name);
	      cn_api.get_fnd_message(l_msg_count, l_msg_data);
	      UPDATE cn_clrl_api
		SET loading_status = l_loading_status,
		message_text = l_msg_data,
		return_status = l_return_status
		WHERE ruleset_name = i.ruleset_name
		AND start_date = i.start_date
		AND end_date = i.end_date
		AND (loading_status <> 'CN_INSERTED' OR loading_status IS NULL);

	   END IF;
	 ELSE
	      UPDATE cn_clrl_api
		SET loading_status = 'CN_ALREADY_EXISTS',
		message_text = l_msg_data,
		return_status = l_return_status
		WHERE ruleset_name = i.ruleset_name
		AND start_date = i.start_date
		AND end_date = i.end_date
		AND (loading_status <> 'CN_INSERTED' OR loading_status IS NULL);

	END IF;


	FOR j IN top_level_rules(i.ruleset_name, i.start_date, i.end_date)
	  LOOP
	     FOR k IN rules(i.ruleset_name, i.start_date, i.end_date, j.rule_name)
	       LOOP

		  l_rule_rec.ruleset_name := i.ruleset_name;
		  l_rule_rec.start_date := i.start_date;
		  l_rule_rec.end_date := i.end_date;
		  l_rule_rec.rule_name := k.rule_name;
		  l_rule_rec.parent_rule_name := k.parent_rule_name;
		  l_rule_rec.revenue_class_name := k.revenue_class_name;

		  cn_rule_pub.create_rule
		    ( p_api_version      => 1.0,
		      p_init_msg_list    => fnd_api.g_true,
		      p_commit           => FND_API.G_FALSE,
		      p_validation_level => FND_API.G_VALID_LEVEL_FULL,
		      x_return_status    => l_return_status,
		      x_msg_count        => l_msg_count,
		      x_msg_data         => l_msg_data,
		      x_loading_status   => l_loading_status,
		      p_rule_rec         => l_rule_rec);


		  IF(l_return_status = FND_API.g_ret_sts_success) THEN

		     UPDATE cn_clrl_api
		       SET loading_status = 'CN_RULE_INSERTED'
		       WHERE ruleset_name = i.ruleset_name
		       AND start_date = i.start_date
		       AND end_date = i.end_date
		       AND rule_name = k.rule_name
		       AND parent_rule_name = k.parent_rule_name
		       AND (loading_status <> 'CN_INSERTED' OR loading_status IS NULL);

		   ELSE
		     SELECT COUNT(1)
		       INTO l_count
		       FROM cn_clrl_api
		       WHERE ruleset_name = i.ruleset_name
		       AND start_date = i.start_date
		       AND end_date = i.end_date
		       AND rule_name = k.rule_name
		       AND parent_rule_name = k.parent_rule_name
		       AND attribute_rule_name IS NOT NULL
			 AND (loading_status <> 'CN_INSERTED' OR loading_status IS NULL);


			 IF l_count <> 0 AND l_loading_status <> 'CN_INVALID_RULE_NAME'
			   THEN
			    UPDATE cn_clrl_api
			      SET loading_status = l_loading_status,
			      return_status = l_return_status,
			      message_text = l_msg_data
			      WHERE ruleset_name = i.ruleset_name
			      AND start_date = i.start_date
			      AND end_date = i.end_date
			      AND rule_name = k.rule_name
			      AND parent_rule_name = k.parent_rule_name
			      AND (loading_status <> 'CN_INSERTED'
				   OR loading_status IS NULL);

				   -- retcode 0 = success, 1 = warning, 2 = error

				   retcode := 2;

				   cn_message_pkg.debug('Error for rule : '||
							k.rule_name||
							' with parent rule : '||
							k.parent_rule_name);


			 END IF;
		  END IF;

		  FOR l IN rule_attributes(i.ruleset_name,
					   i.start_date,
					   i.end_date,
					   k.rule_name,
					   k.parent_rule_name)
		    LOOP

		       l_ruleattribute_rec.ruleset_name := i.ruleset_name;
		       l_ruleattribute_rec.start_date := i.end_date;
		       l_ruleattribute_rec.end_date := i.end_date;
		       l_ruleattribute_rec.rule_name := k.rule_name;
		       l_ruleattribute_rec.object_name := l.object_name;
                       l_ruleattribute_rec.not_flag := l.not_flag;
		       l_ruleattribute_rec.value_1 := l.value_1;
		       l_ruleattribute_rec.value_2 := l.value_2;
		       l_ruleattribute_rec.data_flag := l.data_flag;

		       cn_ruleattribute_pub.create_ruleattribute
			 ( p_api_version      => 1.0,
			   p_init_msg_list    => fnd_api.g_true,
			   p_commit           => FND_API.G_FALSE,
			   p_validation_level => FND_API.G_VALID_LEVEL_FULL,
			   x_return_status    => l_return_status,
			   x_msg_count        => l_msg_count,
			   x_msg_data         => l_msg_data,
			   x_loading_status   => l_loading_status,
			   p_ruleattribute_rec=> l_ruleattribute_rec);


		       IF(l_return_status = FND_API.g_ret_sts_success) THEN

			  UPDATE cn_clrl_api
			    SET loading_status = 'CN_INSERTED'
			    WHERE ruleset_name = i.ruleset_name
			    AND start_date = i.start_date
			    AND end_date = i.end_date
			    AND rule_name = k.rule_name
			    AND parent_rule_name = k.parent_rule_name
			    AND object_name = l.object_name
			    AND (loading_status <> 'CN_INSERTED'
				 OR loading_status IS NULL);

			ELSE
			  UPDATE cn_clrl_api
			    SET loading_status = l_loading_status,
			    return_status = l_return_status,
			    message_text = l_msg_data
			    WHERE ruleset_name = i.ruleset_name
			    AND start_date = i.start_date
			    AND end_date = i.end_date
			    AND rule_name = k.rule_name
			    AND parent_rule_name = k.parent_rule_name
			    AND object_name = l.object_name
			    AND (loading_status <> 'CN_INSERTED'
				 OR loading_status IS NULL);

				 -- retcode 0 = success, 1 = warning, 2 = error

				 retcode := 2;

				 cn_message_pkg.debug('Error for rule attribute : '||
						      l.object_name||
						      ' in rule : '||
						      k.rule_name);


		       END IF;

		    END LOOP; --rule attributes

	       END LOOP; --each rule

	  END LOOP; --top level rules

     END LOOP; --rulesets loop

     COMMIT;

   cn_message_pkg.end_batch(l_proc_audit_id);

   --enter error codes for concurrrent program
   IF retcode = 0 THEN
      FND_MESSAGE.SET_NAME ('CN' , 'ALL_PROCESS_DONE_OK');
      FND_MSG_PUB.Add;
      errbuf :=
	FND_MSG_PUB.get
	(p_msg_index => fnd_msg_pub.G_LAST,p_encoded   => FND_API.G_FALSE);
    ELSIF retcode = 1 THEN
      FND_MESSAGE.SET_NAME ('CN' , 'ALL_PROCESS_DONE_WARN');
      FND_MSG_PUB.Add;
      errbuf :=
	FND_MSG_PUB.get
	(p_msg_index => fnd_msg_pub.G_LAST,p_encoded   => FND_API.G_FALSE);
    ELSE
      FND_MESSAGE.SET_NAME ('CN' , 'ALL_PROCESS_DONE_FAIL');
      FND_MSG_PUB.Add;
      errbuf :=
	FND_MSG_PUB.get
	(p_msg_index => fnd_msg_pub.G_LAST,p_encoded   => FND_API.G_FALSE);
   END IF;
   */
   null;
END upload;

-- --------------------------------------------------------------------+
-- Procedure : LOAD_ROW
-- Description : Called by FNDLOAD to upload seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
PROCEDURE LOAD_ROW
  ( x_rule_id IN NUMBER,
    x_ruleset_id IN NUMBER,
    x_package_id IN NUMBER,
    x_revenue_class_id IN NUMBER,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2,
    x_org_id IN NUMBER) IS
       user_id NUMBER;

BEGIN
   -- Validate input data
   IF (x_ruleset_id IS NULL)
     OR (x_name IS NULL) OR (x_rule_id IS NULL) THEN
      GOTO end_load_row;
   END IF;

   IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   -- Load The record to _B table
   UPDATE cn_rules_all_b SET
     ruleset_id = x_ruleset_id,
     revenue_class_id = x_revenue_class_id,
     package_id = x_package_id,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     org_id=x_org_id
     WHERE rule_id = x_rule_id AND ruleset_id = x_ruleset_id AND ORG_ID=x_org_id;

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _B table
      INSERT INTO cn_rules_all_b
	(rule_id,
	 ruleset_id,
	 revenue_class_id,
	 package_id,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 org_id
	 ) values
	(x_rule_id,
	 x_ruleset_id,
	 x_revenue_class_id,
	 x_package_id,
	 sysdate,
	 user_id,
	 sysdate,
	 user_id,
	 0,
	 x_org_id
	 );
   END IF;
   -- Load The record to _TL table
   UPDATE cn_rules_all_tl  SET
     ruleset_id = x_ruleset_id,
     name = x_name,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     org_id=x_org_id,
     source_lang = userenv('LANG')
     WHERE rule_id = x_rule_id AND ruleset_id = x_ruleset_id and org_id=x_org_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   IF (SQL%NOTFOUND) THEN
      -- Insert new record to _TL table
      INSERT INTO cn_rules_all_tl
	(rule_id,
	 ruleset_id,
	 name,
	 creation_date,
	 created_by,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 language,
	 source_lang,
         org_id)
	SELECT
	x_rule_id,
	x_ruleset_id,
	x_name,
	sysdate,
	user_id,
	sysdate,
	user_id,
	0,
	l.language_code,
	userenv('LANG'),
	x_org_id
	FROM fnd_languages l
	WHERE l.installed_flag IN ('I', 'B')
	AND NOT EXISTS
	(SELECT NULL
	 FROM cn_rules_all_tl t
	 WHERE t.rule_id = x_rule_id and t.org_id=x_org_id
	 AND t.language = l.language_code);
   END IF;
   << end_load_row >>
     NULL;
END LOAD_ROW ;

-- --------------------------------------------------------------------+
-- Procedure : TRANSLATE_ROW
-- Description : Called by FNDLOAD to translate seed datas, this procedure
--    only handle seed datas. ORG_ID = -3113
-- --------------------------------------------------------------------+
PROCEDURE TRANSLATE_ROW
  ( x_rule_id IN NUMBER,
    x_ruleset_id IN NUMBER,
    x_name IN VARCHAR2,
    x_owner IN VARCHAR2,
    x_org_id IN NUMBER) IS
       user_id NUMBER;
BEGIN
    -- Validate input data
   IF (x_ruleset_id IS NULL)
     OR (x_name IS NULL) OR (x_rule_id IS NULL) THEN
      GOTO end_translate_row;
   END IF;

   IF (x_owner IS NOT NULL) AND (x_owner = 'SEED') THEN
      user_id := 1;
    ELSE
      user_id := 0;
   END IF;
   -- Update the translation
   UPDATE cn_rules_all_tl  SET
     name = x_name,
     last_update_date = sysdate,
     last_updated_by = user_id,
     last_update_login = 0,
     source_lang = userenv('LANG')
     WHERE rule_id = x_rule_id
     AND   ruleset_id = x_ruleset_id and org_id=x_org_id
     AND userenv('LANG') IN (LANGUAGE, SOURCE_LANG);

   << end_translate_row >>
     NULL;
END TRANSLATE_ROW ;

END cn_syin_rules_pkg;

/
