--------------------------------------------------------
--  DDL for Package Body JTF_IH_WRAP_UPS_SEED_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_IH_WRAP_UPS_SEED_PUB" AS
 /* $Header: JTFIHWPB.pls 120.3 2006/04/27 07:41:57 rdday ship $ */


     PROCEDURE insert_row(
          x_rowid                          IN OUT NOCOPY VARCHAR2
        , x_wrap_id                          NUMBER
        , x_object_version_number            NUMBER
        , x_created_by                       NUMBER
        , x_creation_date                    DATE
        , x_last_updated_by                  NUMBER
        , x_last_update_date                 DATE
        , x_last_update_login                NUMBER
        , x_outcome_required                 VARCHAR2
        , x_result_required                  VARCHAR2
        , x_reason_required                  VARCHAR2
        , x_result_id                        NUMBER
        , x_reason_id                        NUMBER
        , x_outcome_id                       NUMBER
        , x_action_activity_id               NUMBER
        , x_object_id                        NUMBER
        , x_object_type                      VARCHAR2
        , x_source_code_id                   NUMBER
        , x_source_code                      VARCHAR2
        , x_start_date                       DATE
        , x_end_date                         DATE
        , x_wrap_up_level                    VARCHAR2
     ) IS
        CURSOR l_insert IS
          SELECT ROWID
          FROM jtf_ih_wrap_ups
          WHERE wrap_id = x_wrap_id;
     BEGIN
        INSERT INTO jtf_ih_wrap_ups (
          wrap_id
        , object_version_number
        , created_by
        , creation_date
        , last_updated_by
        , last_update_date
        , last_update_login
        , outcome_required
        , result_required
        , reason_required
        , result_id
        , reason_id
        , outcome_id
        , action_activity_id
        , object_id
        , object_type
        , source_code_id
        , source_code
        , start_date
        , end_date
        , wrap_up_level
        ) VALUES (
          x_wrap_id
        , DECODE(x_object_version_number,FND_API.G_MISS_NUM,NULL,x_object_version_number)
        , DECODE(x_created_by,FND_API.G_MISS_NUM,NULL,x_created_by)
        , DECODE(x_creation_date,FND_API.G_MISS_DATE,NULL,x_creation_date)
        , DECODE(x_last_updated_by,FND_API.G_MISS_NUM,NULL,x_last_updated_by)
        , DECODE(x_last_update_date,FND_API.G_MISS_DATE,NULL,x_last_update_date)
        , DECODE(x_last_update_login,FND_API.G_MISS_NUM,NULL,x_last_update_login)
        , DECODE(x_outcome_required,FND_API.G_MISS_CHAR,NULL,x_outcome_required)
        , DECODE(x_result_required,FND_API.G_MISS_CHAR,NULL,x_result_required)
        , DECODE(x_reason_required,FND_API.G_MISS_CHAR,NULL,x_reason_required)
        , DECODE(x_result_id,FND_API.G_MISS_NUM,NULL,x_result_id)
        , DECODE(x_reason_id,FND_API.G_MISS_NUM,NULL,x_reason_id)
        , DECODE(x_outcome_id,FND_API.G_MISS_NUM,NULL,x_outcome_id)
        , DECODE(x_action_activity_id,FND_API.G_MISS_NUM,NULL,x_action_activity_id)
        , DECODE(x_object_id,FND_API.G_MISS_NUM,NULL,x_object_id)
        , DECODE(x_object_type,FND_API.G_MISS_CHAR,NULL,x_object_type)
        , DECODE(x_source_code_id,FND_API.G_MISS_NUM,NULL,x_source_code_id)
        , DECODE(x_source_code,FND_API.G_MISS_CHAR,NULL,x_source_code)
        , DECODE(x_start_date, FND_API.G_MISS_DATE, SYSDATE, NULL, SYSDATE, x_start_date)
        , x_end_date
        , DECODE(x_wrap_up_level, FND_API.G_MISS_CHAR,'BOTH',NULL,'BOTH',x_wrap_up_level)
        );

        OPEN l_insert;
        FETCH l_insert INTO x_rowid;
        IF (l_insert%NOTFOUND) THEN
            CLOSE l_insert;
            RAISE NO_DATA_FOUND;
        END IF;
     END insert_row;

     PROCEDURE delete_row(
        x_wrap_id                          NUMBER
     ) IS
     BEGIN
        DELETE FROM jtf_ih_wrap_ups
        WHERE wrap_id = x_wrap_id;
        IF (SQL%NOTFOUND) THEN
            RAISE NO_DATA_FOUND;
        END IF;
     END delete_row;

     PROCEDURE update_row(
          x_wrap_id                        NUMBER
        , x_object_version_number          NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_outcome_required               VARCHAR2
        , x_result_required                VARCHAR2
        , x_reason_required                VARCHAR2
        , x_result_id                      NUMBER
        , x_reason_id                      NUMBER
        , x_outcome_id                     NUMBER
        , x_action_activity_id             NUMBER
        , x_object_id                      NUMBER
        , x_object_type                    VARCHAR2
        , x_source_code_id                 NUMBER
        , x_source_code                    VARCHAR2
        , x_start_date                     DATE
        , x_end_date                       DATE
        , x_wrap_up_level                  VARCHAR2
     ) IS
     CURSOR cWrapUps IS SELECT * FROM JTF_IH_WRAP_UPS WHERE WRAP_ID = x_wrap_id;
     rWrapUPS cWrapUps%ROWTYPE;
     l_wrap_id                        NUMBER;
     l_object_version_number          NUMBER;
     l_created_by                     NUMBER;
     l_creation_date                  DATE;
     l_last_updated_by                NUMBER;
     l_last_update_date               DATE;
     l_last_update_login              NUMBER;
     l_outcome_required               VARCHAR2(1);
     l_result_required                VARCHAR2(1);
     l_reason_required                VARCHAR2(1);
     l_result_id                      NUMBER;
     l_reason_id                      NUMBER;
     l_outcome_id                     NUMBER;
     l_action_activity_id             NUMBER;
     l_object_id                      NUMBER;
     l_object_type                    VARCHAR2(30);
     l_source_code_id                 NUMBER;
     l_source_code                    VARCHAR2(100);
     l_start_date                     DATE;
     l_end_date                       DATE;
     l_wrap_up_level                  VARCHAR2(30);

     BEGIN
     	l_wrap_id                        := x_wrap_id;
     	l_object_version_number          := x_object_version_number;
     	l_created_by                     := x_created_by;
     	l_creation_date                  := x_creation_date;
     	l_last_updated_by                := x_last_updated_by;
     	l_last_update_date               := x_last_update_date;
     	l_last_update_login              := x_last_update_login;
     	l_outcome_required               := x_outcome_required;
     	l_result_required                := x_result_required;
     	l_reason_required                := x_reason_required;
     	l_result_id                      := x_result_id;
     	l_reason_id                      := x_reason_id;
     	l_outcome_id                     := x_outcome_id;
     	l_action_activity_id             := x_action_activity_id;
     	l_object_id                      := x_object_id;
     	l_object_type                    := x_object_type;
     	l_source_code_id                 := x_source_code_id;
     	l_source_code                    := x_source_code;
     	l_start_date                     := NVL(x_start_date,SYSDATE);
     	l_end_date                       := x_end_date;
     	l_wrap_up_level                  := x_wrap_up_level;

        IF x_wrap_id IS NULL THEN
            RAISE NO_DATA_FOUND;
        END IF;

        OPEN cWrapUps;
        FETCH cWrapUps INTO rWrapUPS;
        IF cWrapUps%NOTFOUND THEN
            RAISE NO_DATA_FOUND;
        END IF;

        IF(l_object_version_number IS NULL) THEN
            l_object_version_number := rWrapUPS.object_version_number;
        END IF;
        IF(l_created_by IS NULL) THEN
            l_created_by := rWrapUPS.created_by;
        END IF;
        IF(l_last_updated_by IS NULL) THEN
            l_last_updated_by := rWrapUPS.last_updated_by;
        END IF;
        IF(l_last_update_date IS NULL) THEN
            l_last_update_date := sysdate;
        END IF;
        IF(l_last_update_login IS NULL) THEN
            l_last_update_login := -1;
        END IF;
        IF(l_outcome_required IS NULL) THEN
            l_outcome_required := rWrapUPS.outcome_required;
        END IF;
        IF(l_reason_required IS NULL) THEN
            l_reason_required := rWrapUPS.reason_required;
        END IF;
        IF(l_result_required IS NULL) THEN
            l_result_required := rWrapUPS.result_required;
        END IF;
        IF(l_result_id IS NULL) THEN
            l_result_id := rWrapUPS.result_id;
        END IF;
        IF(l_reason_id IS NULL) THEN
            l_reason_id := rWrapUPS.reason_id;
        END IF;
        IF(l_outcome_id IS NULL) THEN
            l_outcome_id := rWrapUPS.outcome_id;
        END IF;
        IF(l_action_activity_id IS NULL) THEN
            l_action_activity_id := rWrapUPS.action_activity_id;
        END IF;
        IF(l_object_id IS NULL) THEN
            l_object_id := rWrapUPS.object_id;
        END IF;
        IF(l_object_type IS NULL) THEN
            l_object_type := rWrapUPS.object_type;
        END IF;
        IF(l_source_code_id IS NULL) THEN
            l_source_code_id := rWrapUPS.source_code_id;
        END IF;
        IF(l_source_code IS NULL) THEN
            l_source_code := rWrapUPS.source_code;
        END IF;
        IF(l_start_date IS NULL) THEN
            l_start_date := rWrapUPS.start_date;
        END IF;
        IF(l_end_date IS NULL) THEN
            l_end_date := rWrapUPS.end_date;
        END IF;
        IF(l_wrap_up_level IS NULL) THEN
            l_wrap_up_level := rWrapUPS.wrap_up_level;
        END IF;

        UPDATE jtf_ih_wrap_ups
        SET
         object_version_number=l_object_version_number
        , last_updated_by =l_last_updated_by
        , last_update_date = l_last_update_date
        , last_update_login =l_last_update_login
        , outcome_required =l_outcome_required
        , result_required =l_result_required
        , reason_required =l_reason_required
        , result_id =l_result_id
        , reason_id =l_reason_id
        , outcome_id =l_outcome_id
        , action_activity_id =l_action_activity_id
        , object_id =l_object_id
        , object_type=l_object_type
        , source_code_id=l_source_code_id
        , source_code=l_source_code
        , start_date = l_start_date
        , end_date = l_end_date
        , wrap_up_level = l_wrap_up_level
        WHERE WRAP_ID = l_wrap_id;

        IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;
     END update_row;

     PROCEDURE lock_row(
          x_rowid                          VARCHAR2
        , x_wrap_id                        NUMBER
        , x_object_version_number          NUMBER
        , x_created_by                     NUMBER
        , x_creation_date                  DATE
        , x_last_updated_by                NUMBER
        , x_last_update_date               DATE
        , x_last_update_login              NUMBER
        , x_outcome_required               VARCHAR2
        , x_result_required                VARCHAR2
        , x_reason_required                VARCHAR2
        , x_result_id                      NUMBER
        , x_reason_id                      NUMBER
        , x_outcome_id                     NUMBER
        , x_action_activity_id             NUMBER
        , x_object_id                      NUMBER
        , x_object_type                    VARCHAR2
        , x_source_code_id                 NUMBER
        , x_source_code                    VARCHAR2
     ) IS
        -- bug# 2500341
        CURSOR l_lock IS
          SELECT *
          FROM jtf_ih_wrap_ups
          WHERE wrap_id = x_wrap_id
          FOR UPDATE OF wrap_id NOWAIT;
        l_table_rec l_lock%ROWTYPE;
     BEGIN
        OPEN l_lock;
        FETCH l_lock INTO l_table_rec;
        IF (l_lock%NOTFOUND) THEN
             CLOSE l_lock;
             FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
             APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
        CLOSE l_lock;
        IF (
          ((l_table_rec.wrap_id = x_wrap_id)
            OR ((l_table_rec.wrap_id IS NULL)
                AND ( x_wrap_id IS NULL)))
          AND           ((l_table_rec.object_version_number = x_object_version_number)
            OR ((l_table_rec.object_version_number IS NULL)
                AND ( x_object_version_number IS NULL)))
          AND           ((l_table_rec.created_by = x_created_by)
            OR ((l_table_rec.created_by IS NULL)
                AND ( x_created_by IS NULL)))
          AND           ((l_table_rec.creation_date = x_creation_date)
            OR ((l_table_rec.creation_date IS NULL)
                AND ( x_creation_date IS NULL)))
          AND           ((l_table_rec.last_updated_by = x_last_updated_by)
            OR ((l_table_rec.last_updated_by IS NULL)
                AND ( x_last_updated_by IS NULL)))
          AND           ((l_table_rec.last_update_date = x_last_update_date)
            OR ((l_table_rec.last_update_date IS NULL)
                AND ( x_last_update_date IS NULL)))
          AND           ((l_table_rec.last_update_login = x_last_update_login)
            OR ((l_table_rec.last_update_login IS NULL)
                AND ( x_last_update_login IS NULL)))
          AND           ((l_table_rec.outcome_required = x_outcome_required)
            OR ((l_table_rec.outcome_required IS NULL)
                AND ( x_outcome_required IS NULL)))
          AND           ((l_table_rec.result_required = x_result_required)
            OR ((l_table_rec.result_required IS NULL)
                AND ( x_result_required IS NULL)))
          AND           ((l_table_rec.reason_required = x_reason_required)
            OR ((l_table_rec.reason_required IS NULL)
                AND ( x_reason_required IS NULL)))
          AND           ((l_table_rec.result_id = x_result_id)
            OR ((l_table_rec.result_id IS NULL)
                AND ( x_result_id IS NULL)))
          AND           ((l_table_rec.reason_id = x_reason_id)
            OR ((l_table_rec.reason_id IS NULL)
                AND ( x_reason_id IS NULL)))
          AND           ((l_table_rec.outcome_id = x_outcome_id)
            OR ((l_table_rec.outcome_id IS NULL)
                AND ( x_outcome_id IS NULL)))
          AND           ((l_table_rec.action_activity_id = x_action_activity_id)
            OR ((l_table_rec.action_activity_id IS NULL)
                AND ( x_action_activity_id IS NULL)))
          AND           ((l_table_rec.object_id = x_object_id)
            OR ((l_table_rec.object_id IS NULL)
                AND ( x_object_id IS NULL)))
          AND           ((l_table_rec.object_type = x_object_type)
            OR ((l_table_rec.object_type IS NULL)
                AND ( x_object_type IS NULL)))
          AND           ((l_table_rec.source_code_id = x_source_code_id)
            OR ((l_table_rec.source_code_id IS NULL)
                AND ( x_source_code_id IS NULL)))
          AND           ((l_table_rec.source_code = x_source_code)
            OR ((l_table_rec.source_code IS NULL)
                AND ( x_source_code IS NULL)))
        ) THEN
          RETURN;
        ELSE
          FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
     END lock_row;


    PROCEDURE load_row(
          x_wrap_id                           NUMBER
        , x_object_version_number             NUMBER
        , x_outcome_required                  VARCHAR2
        , x_result_required                   VARCHAR2
        , x_reason_required                   VARCHAR2
        , x_result_id                         NUMBER
        , x_reason_id                         NUMBER
        , x_outcome_id                        NUMBER
        , x_action_activity_id                NUMBER
        , x_object_id                         NUMBER
        , x_object_type                       VARCHAR2
        , x_source_code_id                    NUMBER
        , x_source_code                       VARCHAR2
        , x_start_date                        DATE
        , x_end_date                          DATE
        , x_owner                             VARCHAR2
        , x_wrap_up_level                     VARCHAR2
    )
    AS
    user_id                          NUMBER := 0;
    row_id                           VARCHAR2(64);
    l_wrap_id                        NUMBER;
    l_object_version_number          NUMBER;
    l_outcome_required               VARCHAR2(1);
    l_result_required                VARCHAR2(1);
    l_reason_required                VARCHAR2(1);
    l_result_id                      NUMBER;
    l_reason_id                      NUMBER;
    l_outcome_id                     NUMBER;
    l_action_activity_id             NUMBER;
    l_object_id                      NUMBER;
    l_object_type                    VARCHAR2(30);
    l_source_code_id                 NUMBER;
    l_source_code                    VARCHAR2(100);
    l_start_date                     DATE;
    l_end_date                       DATE;
    l_wrap_up_level                  VARCHAR2(30);

    l_Sql                            VARCHAR2(2000);
    n_Wrap_Id                        NUMBER;
    n_Cursor                         BINARY_INTEGER;
    n_Res                            BINARY_INTEGER;

    type rec_Params is record (
            name varchar2(30),
            value number);
    type tbl_Params is table of rec_Params index by binary_integer;
        v_Params tbl_Params;
    n_CntParams number;
    l_param_name varchar2(30);
    l_param_value number;

    BEGIN
	   --if (x_owner = 'SEED') then
 	   --	  user_id := 1;
	   --end if;
        user_id := fnd_load_util.owner_id(x_owner);
        l_wrap_id                        := x_wrap_id;
        l_object_version_number          := x_object_version_number;
        l_outcome_required               := x_outcome_required;
        l_result_required                := x_result_required;
        l_reason_required                := x_reason_required;
        l_result_id                      := x_result_id;
        l_reason_id                      := x_reason_id;
        l_outcome_id                     := x_outcome_id;
        l_action_activity_id             := x_action_activity_id;
        l_object_id                      := x_object_id;
        l_object_type                    := x_object_type;
        l_source_code_id                 := x_source_code_id;
        l_source_code                    := x_source_code;
        l_start_date                     := NVL(x_start_date,SYSDATE);
        l_end_date                       := x_end_date;
        l_wrap_up_level                  := x_wrap_up_level;

        -- Check Wrap_Up on duplicate values.
        --
        l_Sql := 'SELECT Wrap_Id FROM jtf_ih_wrap_ups WHERE Outcome_ID = :outcome_id ';
        n_CntParams := 1;
        v_Params(n_CntParams).name := ':outcome_id';
        v_Params(n_CntParams).value := l_outcome_id;
            IF l_result_id IS NOT NULL THEN
                -- l_Sql := l_Sql || 'AND result_id = '''||l_result_id||''' ';
                l_Sql := l_Sql || 'AND result_id = :result_id ';
                n_CntParams := n_CntParams + 1;
                v_Params(n_CntParams).name := ':result_id';
                v_Params(n_CntParams).value := l_result_id;
            ELSE
                l_Sql := l_Sql || 'AND result_id IS NULL ';
            END IF;
            IF l_reason_id IS NOT NULL THEN
                --l_Sql := l_Sql || 'AND reason_id = '''||l_reason_id||''' ';
                l_Sql := l_Sql || 'AND reason_id = :reason_id ';
                n_CntParams := n_CntParams + 1;
                v_Params(n_CntParams).name := ':reason_id';
                v_Params(n_CntParams).value := l_reason_id;
            ELSE
                l_Sql := l_Sql || 'AND reason_id IS NULL ';
            END IF;
            IF l_source_code IS NOT NULL THEN
                --l_Sql := l_Sql || 'AND source_code = '''||l_source_code||''' ';
                l_Sql := l_Sql || 'AND source_code = :source_code ';
                n_CntParams := n_CntParams + 1;
                v_Params(n_CntParams).name := ':source_code';
                v_Params(n_CntParams).value := l_source_code;
            ELSE
                l_Sql := l_Sql || 'AND source_code IS NULL ';
            END IF;
            IF l_source_code_id IS NOT NULL THEN
                --l_Sql := l_Sql || 'AND source_code_id = '''||l_source_code_id||''' ';
                l_Sql := l_Sql || 'AND source_code = :source_code_id ';
                n_CntParams := n_CntParams + 1;
                v_Params(n_CntParams).name := ':source_code_id';
                v_Params(n_CntParams).value := l_source_code_id;

            ELSE
                l_Sql := l_Sql || 'AND source_code_id IS NULL ';
            END IF;
            l_Sql := l_Sql || 'ORDER BY wrap_id';
            --dbms_output.put_line(l_Sql);
            BEGIN
                n_Cursor := dbms_sql.open_cursor;
                dbms_sql.parse(n_Cursor, l_Sql, dbms_sql.native);
                FOR i IN 1..v_Params.count LOOP
                    dbms_sql.bind_variable(n_Cursor,v_Params(i).name,v_Params(i).value);
                END LOOP;
                dbms_sql.define_column(n_Cursor,1,n_Wrap_Id);
                n_Res := dbms_sql.execute(n_Cursor);
                LOOP
                    IF dbms_sql.fetch_rows(n_Cursor) = 0 THEN
                        EXIT;
                    END IF;
                    dbms_sql.column_value(n_Cursor,1,n_Wrap_Id);
                END LOOP;
            END;
            --dbms_output.put_line('Pass l_wrap_id = '||l_wrap_id);
            --dbms_output.put_line('Get n_Wrap_Id = '||n_Wrap_Id);
            --
            -- Bug#3362889
            BEGIN
            	IF ((n_Wrap_Id IS NOT NULL) AND (l_wrap_id <> n_Wrap_Id)) THEN
                    IF ((n_Wrap_Id > l_wrap_id) AND (l_wrap_id < 10000)) THEN
                        -- dbms_output.put_line('Update JTF_IH_ACTION_ACTION_ITEMS');
                        UPDATE jtf_ih_wrap_ups SET wrap_id = l_wrap_id WHERE wrap_id = n_Wrap_Id;
                        UPDATE jtf_ih_action_action_items SET default_wrap_id = l_wrap_id
                            WHERE default_wrap_id = n_Wrap_Id;
                    ELSE
                        l_wrap_id := n_Wrap_Id;
                    END IF;
            	END IF;
            --dbms_output.put_line('Wrap_ID = '||l_wrap_id);

        		update_row(
          		x_wrap_id => l_wrap_id
        		, x_object_version_number => l_object_version_number
        		, x_created_by => null
        		, x_creation_date => null
        		, x_last_updated_by => user_id
        		, x_last_update_date => sysdate
        		, x_last_update_login => 0
        		, x_outcome_required => l_outcome_required
        		, x_result_required => l_result_required
        		, x_reason_required => l_reason_required
        		, x_result_id => l_result_id
        		, x_reason_id => l_reason_id
        		, x_outcome_id => l_outcome_id
        		, x_action_activity_id => l_action_activity_id
        		, x_object_id => l_object_id
        		, x_object_type => l_object_type
        		, x_source_code_id => l_source_code_id
        		, x_source_code => l_source_code
        		, x_start_date => l_start_date
        		, x_end_date => l_end_date
        		, x_wrap_up_level => l_wrap_up_level);
        	EXCEPTION
        		WHEN DUP_VAL_ON_INDEX THEN
        			NULL;
			END;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
                insert_row(
                    x_rowid => row_id
                    , x_wrap_id => l_wrap_id
                    , x_object_version_number => l_object_version_number
                    , x_created_by => user_id
                    , x_creation_date => sysdate
                    , x_last_updated_by => user_id
                    , x_last_update_date => sysdate
                    , x_last_update_login => 0
                    , x_outcome_required => l_outcome_required
                    , x_result_required => l_result_required
                    , x_reason_required => l_reason_required
                    , x_result_id => l_result_id
                    , x_reason_id => l_reason_id
                    , x_outcome_id => l_outcome_id
                    , x_action_activity_id => l_action_activity_id
                    , x_object_id => l_object_id
                    , x_object_type => l_object_type
                    , x_source_code_id => l_source_code_id
                    , x_source_code => l_source_code
                    , x_start_date => l_start_date
                    , x_end_date => l_end_date
                    , x_wrap_up_level => l_wrap_up_level
                    );
                    --dbms_output.put_line('Insert!');
    END load_row;
PROCEDURE load_seed_row(
          x_wrap_id                           NUMBER
        , x_object_version_number             NUMBER
        , x_outcome_required                  VARCHAR2
        , x_result_required                   VARCHAR2
        , x_reason_required                   VARCHAR2
        , x_result_id                         NUMBER
        , x_reason_id                         NUMBER
        , x_outcome_id                        NUMBER
        , x_action_activity_id                NUMBER
        , x_object_id                         NUMBER
        , x_object_type                       VARCHAR2
        , x_source_code_id                    NUMBER
        , x_source_code                       VARCHAR2
        , x_start_date                        DATE DEFAULT NULL
        , x_end_date                          DATE DEFAULT NULL
        , x_owner                             VARCHAR2
        , x_wrap_up_level                     VARCHAR2
        , x_upload_mode                       VARCHAR2
    )AS
BEGIN
	JTF_IH_WRAP_UPS_SEED_PUB.LOAD_ROW(
                          x_wrap_id
                        , x_object_version_number
                        , x_outcome_required
                        , x_result_required
                        , x_reason_required
                        , x_result_id
                        , x_reason_id
                        , x_outcome_id
                        , x_action_activity_id
                        , x_object_id
                        , x_object_type
                        , x_source_code_id
                        , x_source_code
                        , x_start_date
                        , x_end_date
                        , x_owner
                        , x_wrap_up_level);
end LOAD_SEED_ROW;

END JTF_IH_WRAP_UPS_SEED_PUB;

/
