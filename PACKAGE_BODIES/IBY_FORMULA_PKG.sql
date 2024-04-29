--------------------------------------------------------
--  DDL for Package Body IBY_FORMULA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBY_FORMULA_PKG" AS
/*$Header: ibyformb.pls 115.12 2002/11/19 00:20:02 jleybovi ship $*/

    /*
    ** Name : getPayeeFormula
    ** Purpose : Retrieves the payee Formula records into o_RiskFormula
    **           corresponding to payeeid.
    */
    PROCEDURE getPayeeFormulas( i_payeeid IN VARCHAR2,
                            o_RiskFormula out nocopy formula_table)
    IS

    CURSOR c_formulas(ci_payeeid iby_risk_formulas.payeeid%TYPE) is
        SELECT risk_formula_id, formula_name, description, implicit_flag
        FROM iby_risk_formulas
        WHERE payeeid = ci_payeeid
        order by creation_date;

    l_count INTEGER;

    BEGIN

        /*
        ** If the cursor is already open close the cursor
        ** and then call open, otherwise SQL raises an exception.
        */
        IF ( c_formulas%ISOPEN ) THEN
            CLOSE c_formulas;
        END IF;


        l_count := 0;

        /*
        ** open the cursor in for loop and load all the formulas
        ** associated with the payeeid passed.
        */

        FOR i in c_formulas(i_payeeid) LOOP
            o_RiskFormula(l_count).id := i.risk_formula_id;
            o_RiskFormula(l_count).name := i.formula_name;
            o_RiskFormula(l_count).description := i.description;
            o_RiskFormula(l_count).flag := i.implicit_flag;
            l_count := l_count + 1;
        END LOOP;

    END getPayeeFormulas;

    /*
    ** Name : createFormula
    ** Purpose : Creates a new formula in the database for the payee Id passed
    **           and returns back the formula Is as output parameter.
    */

    Procedure createFormula( i_payeeId in VARCHAR2,
                             i_name in VARCHAR2,
                             i_description in VARCHAR2,
                             i_flag in integer,
                             i_count in integer,
                             i_Factors in factor_table,
                             o_id out nocopy integer)
    IS

    CURSOR c_formula_id is
    SELECT IBY_RISK_FORMULAS_S.NEXTVAL
    FROM DUAL;

    CURSOR c_factor_id( ci_factor_name VARCHAR2) is
    SELECT risk_factor_id
    FROM iby_risk_factors
    WHERE risk_factor_code = ci_factor_name;

    l_formula_id integer;
    l_factor_id integer;
    i integer;

    BEGIN

        /*
        ** Check if this Formula Name already exists with that Payee
        ** or not. if exists, then raise an exception.
        */
        SELECT count(*) INTO i
        FROM iby_risk_formulas
        WHERE formula_name = i_name
          AND payeeid = i_payeeid;

        IF ( i <> 0 ) then
            RAISE_APPLICATION_ERROR(-20000, 'IBY_204227#FORMULANAME=' ||
                  i_name || '#' );
        END IF;


        /*
        ** close the cursor, if it is already open.
        */
        IF ( c_formula_id%isopen ) THEN
            CLOSE c_formula_id;
        END IF;

        /*
        ** Get the next formula Id available from the sequence.
        */
        OPEN c_formula_id;
        fetch c_formula_id into l_formula_id;
        CLOSE c_formula_id;

        -- Insert Factors.

        i := i_count;

        WHILE ( i > 0 ) LOOP
            -- get Factor Id.
            IF ( c_factor_id%ISOPEN ) THEN
               CLOSE c_factor_id;
            END IF;
            OPEN c_factor_id(i_factors(i).name);
            FETCH c_factor_id into l_factor_id;
            -- If the factor Id is not found then raise exception.
            IF ( c_factor_id%NOTFOUND ) then
                CLOSE c_factor_id;
                RAISE_APPLICATION_ERROR(-20000, 'IBY_204226#FACTORNAME='
                     || i_factors(i).name || '#');
            END IF;

            CLOSE c_factor_id;

            -- insert the record into iby_risk_formula_item;

            INSERT INTO iby_risk_formula_item
                (risk_factor_id, risk_formula_id,
                 weight,object_version_number,
                 last_update_date, last_updated_by,
                 creation_date, created_by)
            VALUES ( l_factor_id, l_formula_id,
                 i_factors(i).weight, 1,
                 sysdate, fnd_global.user_id,
                 sysdate, fnd_global.user_id);

            -- decrement index.
            i := i - 1;

        END LOOP;

        -- make entry in the formulas table once all the factors are
        -- inserted.
        INSERT INTO iby_risk_formulas
               ( risk_formula_id, formula_name, description,
                implicit_flag, payeeid,object_version_number,
                last_update_date, last_updated_by,
                creation_date, created_by)
        VALUES ( l_formula_id, i_name, i_description,
                i_flag, i_payeeId, 1,
                sysdate, fnd_global.user_id,
                sysdate, fnd_global.user_id);
        -- commit the changes
        commit;

    END createFormula;

    /*
    ** Name : modifyFormula
    ** Purpose : modifies the formula information corresponding to the
    **           formulaId with the passed information in the database.
    */
    PROCEDURE modifyFormula( i_id IN INTEGER,
                             i_name IN VARCHAR2,
                             i_description IN VARCHAR2,
                             i_flag in integer,
                             i_count IN INTEGER,
                             i_Factors IN factor_table)
    IS

    CURSOR c_factor_id( ci_factor_name VARCHAR2) is
    SELECT risk_factor_id
    FROM iby_risk_factors
    WHERE risk_factor_code = ci_factor_name;

    l_formula_id integer;
    l_factor_id integer;
    i integer;

    BEGIN

        /*
        ** check if the modified name is already exists in
        ** the formula list that is associated with that payeeid.
        ** The following query retrieves count of no of rows
        ** whose formula_name is same as the name passed in, and
        ** payee id corresponding to it is same as the one associated
        ** with the formula id.
        */
        SELECT count(*) INTO i
        FROM iby_risk_formulas
        WHERE formula_name = i_name
        and risk_formula_id <> i_id
        and payeeid  =  ( SELECT payeeid
                          FROM iby_risk_formulas
                          WHERE risk_formula_id = i_id );

        /*
        ** if count is not zero, that means  already some
        ** row present with the same name. So, raise an exception
        ** for violating unique name constraint.
        */
        IF ( i <> 0 ) then
            RAISE_APPLICATION_ERROR(-20000, 'IBY_204227#FORMULANAME=' ||
                  i_name || '#' );
        END IF;

        -- Delete Existing Factors.

           DELETE iby_risk_formula_item
           WHERE risk_formula_id = i_id;

        -- Insert new Factors.

        i := i_count;

        WHILE ( i > 0 ) LOOP
            -- get Factor Id.
            IF ( c_factor_id%ISOPEN ) THEN
               CLOSE c_factor_id;
            END IF;
            OPEN c_factor_id(i_factors(i).name);
            FETCH c_factor_id into l_factor_id;
            IF ( c_factor_id%NOTFOUND ) then
                CLOSE c_factor_id;
                RAISE_APPLICATION_ERROR(-20000, 'IBY_204226#FACTORNAME='
                     || i_factors(i).name || '#');
            END IF;

            CLOSE c_factor_id;

            -- insert the record into iby_risk_formula_item;

            INSERT INTO iby_risk_formula_item
                (risk_factor_id, risk_formula_id, weight, object_version_number,
                last_update_date, last_updated_by, creation_date, created_by)
            VALUES ( l_factor_id, i_id, i_factors(i).weight, 1,
                sysdate, fnd_global.user_id, sysdate, fnd_global.user_id);

            -- decrement index.
            i := i - 1;

        END LOOP;

        -- update the formula information.

        UPDATE iby_risk_formulas
           SET formula_name = i_name,
               description = i_description,
               implicit_flag = i_flag,
               last_update_date = sysdate,
               last_updated_by = fnd_global.user_id
           WHERE risk_formula_id = i_id;

        -- if no of rows updated is zero then raise an exception.

        if ( SQL%ROWCOUNT = 0 ) then
            raise_application_error(-20000, 'IBY_204225#');
        end if;
        -- commit the changes
        commit;
    END modifyFormula;

    /*
    ** Name : deleteFormula
    ** Purpose : deletes the formula corresponding to the formulaId
    **           from the database.
    */
    PROCEDURE deleteFOrmula( i_id in integer)
    IS
    BEGIN

        -- delete the FAcotr items from the iby_risk_formula_item.
        DELETE iby_risk_formula_item
        WHERE risk_formula_id = i_id;

        -- delete the Formula entry from iby_risk_formulas
        DELETE iby_risk_formulas
        WHERE risk_formula_id = i_id;

        if ( SQL%ROWCOUNT = 0 ) then
            raise_application_error(-20000, 'IBY_204225#');
        end if;
        -- commit the changes
        commit;

    END deleteFormula;

    /*
    ** Name : loadFormula
    ** Purpose : Retrievs  the Formula information and loads the
    **           factors of the formula into o_Factors
    **           corresponding to formulaId.
    */
    PROCEDURE loadFormula( i_formulaId IN INTEGER,
                           o_name out nocopy VARCHAR2,
                           o_description out nocopy VARCHAR2,
                           o_flag out nocopy integer,
                           o_Factors out nocopy factor_table)
    IS

    CURSOR c_formulas(ci_risk_formula_id iby_risk_formulas.risk_formula_id%TYPE) is
        SELECT formula_name, description, implicit_flag
        FROM iby_risk_formulas
        WHERE risk_formula_id = ci_risk_formula_id;

    CURSOR c_factor(ci_factorid iby_risk_formula_item.risk_formula_id%type) IS
        SELECT risk_factor_code, weight
        FROM iby_risk_factors irf, iby_risk_formula_item irft
        WHERE irft.risk_formula_id = i_formulaId
          AND irf.risk_factor_id = irft.risk_factor_id;

    l_cnt integer;

    BEGIN

        IF ( c_formulas%ISOPEN ) THEN
            CLOSE c_formulas;
        END IF;

        IF ( c_factor%ISOPEN ) THEN
            CLOSE c_factor;
        END IF;

        -- load formula information first and then factors information
        -- associated with that formula id.
        open c_formulas(i_formulaid);
        fetch c_formulas into o_name, o_description, o_flag;

        -- if there are no risk formulas.
        if ( c_formulas%NOTFOUND ) then
            close c_formulas;
            raise_application_error(-20000, 'IBY_204225#');
        end if;

        close c_formulas;

        l_cnt := 0;

        FOR i IN c_factor(i_formulaid) LOOP
            o_factors(l_cnt).name   := i.risk_factor_code;
            o_factors(l_cnt).weight := i.weight;
            l_cnt := l_cnt + 1;
        END LOOP;

    END loadFormula;

END iby_formula_pkg;


/
