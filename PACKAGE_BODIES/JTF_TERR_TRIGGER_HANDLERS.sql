--------------------------------------------------------
--  DDL for Package Body JTF_TERR_TRIGGER_HANDLERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_TRIGGER_HANDLERS" as
/* $Header: jtftrhdb.pls 115.20 2002/12/18 01:00:32 jdochert ship $ */
--    ---------------------------------------------------
--  Start of Comments
--  ---------------------------------------------------
--  PACKAGE NAME:   JTF_TERR_TRIGGER_HANDLERS
--  ---------------------------------------------------
--  PURPOSE
--    Joint task force core territory manager private api's.
--    This package is defines Territory Trigger handlers.
--    Trigger handler API Spec for TABLES:
--        JTF_TERR, JTF_TERR_VALUES, JTF_TERR_RSC, JTF_TERR_RSC_ACCESS, JTF_TERR_QTYPE_USGS
--    CODE HAS BEEN OPTIMIZED
--
--  Procedures:
--    (see below for specification)
--
--  NOTES
--    This package is available for use
--  HISTORY
--    04/23/00    EIHSU     Created
--    in between  EIHSU     UPDATED to include JTF_TERR_RSC
--    in between  EIHSU     UPDATED to include JTF_TERR_RSC_ACCESS, JTF_TERR_QTYPE_USGS
--    09/07/00    EIHSU     Optimized
--    09/21/00    EIHSU     BUG 1410995, also commented out qual_type_usg_id in update proc
--    09/25/00    EIHSU     EHN BUG 1410995 - changed_terr records deleted upon record deletion
--                                            add request_id is null to all sql's
--    09/26/00    EIHSU     EHN BUG 1410995 - ON-DELETE, sometimes add delete record, sometimes delete ON-INSERT record.
--    09/26/00    EIHSU     EHN BUG 1410995 - when deleting a territory changed_terr record
--                                            also delete all records relating to that terr
--    10/04/00    EIHSU     ENH BUG 1423245, and BUG 1423718
--    10/04/00    EIHSU     Only transactions for sales will be recorded.
--    10/06/00    EIHSU     TERR_PTY transaction: Old values also recorded.
--  End of Comments

--**************************************************************
--  Territory_Trigger_Handler
--**************************************************************
PROCEDURE Territory_Trigger_Handler (
    p_terr_id                       NUMBER,
    p_org_id                        NUMBER,
    o_parent_territory_id           NUMBER,
    o_last_update_date              DATE,
    o_last_updated_by               NUMBER,
    o_creation_date                 DATE,
    o_created_by                    NUMBER,
    o_last_update_login             VARCHAR2,
    o_start_date_active             DATE,
    o_end_date_active               DATE,
    o_rank                          VARCHAR2,
    o_update_flag                   VARCHAR2,
    o_num_winners                   NUMBER,
    n_parent_territory_id           NUMBER,
    n_last_update_date              DATE,
    n_last_updated_by               NUMBER,
    n_creation_date                 DATE,
    n_created_by                    NUMBER,
    n_last_update_login             VARCHAR2,
    n_start_date_active             DATE,
    n_end_date_active               DATE,
    n_rank                          VARCHAR2,
    n_update_flag                   VARCHAR2,
    n_num_winners                   NUMBER,
    Trigger_Mode                    VARCHAR2
)
IS

  Changed_Terr_rec_Exist    Varchar2(30);
  exist_terr_id             NUMBER;
  l_terr_id                 NUMBER;
  l_source_id               NUMBER;
  NOT_SALES_TERR_CHANGE     exception;

BEGIN

    Changed_Terr_rec_Exist := 'False';

    l_terr_id := p_terr_id;

    -- l_terr_value_id := terr_value_id;
    --l_parent_territory_id := o_parent_territory_id;

    -- check source of current territory
    -- only add / modify records in jtf_changed_terr all
    BEGIN
        --dbms_output.put_line('JTF_TERR_TRIGGER_HANDLER: (TERR_VAL)        terr_id = ' || l_terr_id);
        Select source_id into l_source_id
        from jtf_terr_usgs
        where terr_id = l_terr_id
              and source_id = -1001;
    EXCEPTION
        When NO_DATA_FOUND then
            --dbms_output.put_line('JTF_TERR_TRIGGER_HANDLER: (TERR_VAL)        NOT A SALES_TERR_CHANGE, raising exception ');
            raise NOT_SALES_TERR_CHANGE;
    End;

    -- CHECK IF CHANGED_TERR record already exist
    -- Terr_id header change record
    BEGIN
        Select terr_id into exist_terr_id
        from   JTF_CHANGED_TERR
        where   terr_id = l_terr_id
                and terr_rsc_id is null
                and terr_qtype_usg_id is null
                and terr_rsc_access_id is null
                and terr_value_id is null
                and request_id is null;
        Changed_Terr_rec_Exist := 'True';
    EXCEPTION
        When NO_DATA_FOUND then
             Changed_Terr_rec_Exist := 'False';
            --dbms_output.put_line('JTDT- no data found in table');
            exist_terr_id := NULL;
        When OTHERS then
            --dbms_output.put_line('JTDT- error while looking for existing records.');
            FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERRITORIES_BIUD-Handler', 'Error checking for existing terr record(1): ' || sqlerrm);
            null;
    End;

    -- Write to JTF_CHANGED_TERR table in appropriate fasion
    If Trigger_Mode = 'ON-INSERT' then
        --dbms_output.put_line('Terr_Exist: ' || Terr_Exist);

        If Changed_Terr_rec_Exist = 'True' then
            --dbms_output.put_line('JTDT- Updating record to JTF_CHANGED_TERR');
            -- TEST results:
            -- This should nver happen
            BEGIN
                UPDATE JTF_CHANGED_TERR
                SET   -- terr_id = terr_id,
                      Action = 'UPDATE_RECORD',
                      Trigger_mode = 'ON-INSERT',
                      NEW_last_update_date =  n_last_update_date,
                      NEW_last_updated_by = n_last_updated_by,
                      NEW_creation_date = n_creation_date,
                      NEW_created_by = n_created_by,
                      NEW_last_update_login = n_last_update_login,
                      NEW_start_date_active = n_start_date_active,
                      NEW_end_date_active = n_end_date_active,
                      NEW_rank = n_rank,
                      NEW_update_flag = n_update_flag,
                      NEW_num_winners = n_num_winners,
                      NEW_parent_territory_id = n_parent_territory_id
                WHERE terr_id = l_terr_id
                    and terr_rsc_id is null
                    and terr_qtype_usg_id is null
                    and terr_rsc_access_id is null
                    and terr_value_id is null
                    and request_id is null;

            EXCEPTION
                When OTHERS then
                     --dbms_output.put_line('ON-INSERT/UPDATE-TERR: error updating record');
                     FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERRITORIES_BIUD-Handler', 'Error updating record for inserting terr' || sqlerrm);
            End;
        Else -- Terr_Exist = False -- New Territory Added
            -- TEST results:
            BEGIN
                --dbms_output.put_line('JTDT- Inserting record to JTF_CHANGED_TERR');
                INSERT INTO JTF_CHANGED_TERR
    	    	    (terr_id, org_id, Action, Trigger_mode, NEW_last_update_date, NEW_last_updated_by,
                     NEW_creation_date, NEW_created_by, NEW_last_update_login, NEW_start_date_active,
                     NEW_end_date_active, NEW_rank, NEW_update_flag, NEW_num_winners, NEW_parent_territory_id)
            	values
                    (l_terr_id, p_org_id, 'NEW_RECORD', 'ON-INSERT', n_last_update_date, n_last_updated_by,
                     n_creation_date, n_created_by, n_last_update_login, n_start_date_active,
                     n_end_date_active, n_rank, n_update_flag, n_num_winners, n_parent_territory_id);
            EXCEPTION
                When OTHERS then
                     --dbms_output.put_line('ON-INSERT/INSERT-TERR: error updating record');
                     FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERRITORIES_BIUD-Handler', 'Error inserting record for inserting terr' || sqlerrm);
            End;
        End if;
    elsif Trigger_Mode = 'ON-UPDATE' then
        -- (Territory Modified) items that may change:
        -- start_date_active, end_date_active, rank, update_flag
        -- Build update string based on what has actually been modified
        -- If something didn't get modified, we'd still have it in the new field, so forget this dynamic SQL generation
        -- Execute_SQL_STRING := 'UPDATE JTF_CHANGED_TERR SET ';
        If Changed_Terr_rec_Exist = 'True' then
            BEGIN
                UPDATE JTF_CHANGED_TERR
                SET Action =                'UPDATED_RECORD',
                    Trigger_mode =          'ON-UPDATE',
--                    OLD_last_update_date =  o_last_update_date,
--                    OLD_last_updated_by =   o_last_updated_by,
--                    OLD_creation_date =     o_creation_date,
--                    OLD_created_by =        o_created_by,
--                    OLD_last_update_login = o_last_update_login,
--                    OLD_start_date_active = o_start_date_active,
--                    OLD_end_date_active =   o_end_date_active,
--                    OLD_rank =              o_rank,
--                    OLD_update_flag =       o_update_flag,
--                    OLD_num_winners =       o_num_winners,
--                    OLD_parent_territory_id = o_parent_territory_id,
                    NEW_last_update_date =  n_last_update_date,
                    NEW_last_updated_by =   n_last_updated_by,
                    NEW_creation_date =     n_creation_date,
                    NEW_created_by =        n_created_by,
                    NEW_last_update_login = n_last_update_login,
                    NEW_start_date_active = n_start_date_active,
                    NEW_end_date_active =   n_end_date_active,
                    NEW_rank =              n_rank,
                    NEW_update_flag =       n_update_flag,
                    NEW_num_winners =       n_num_winners,
                    NEW_parent_territory_id = n_parent_territory_id
                WHERE terr_id = l_terr_id
                    and terr_rsc_id is null
                    and terr_qtype_usg_id is null
                    and terr_rsc_access_id is null
                    and terr_value_id is null
                    and request_id is null;

            EXCEPTION
                When OTHERS then
                     --dbms_output.put_line('ON-UPDATE/UPDATE-TERR: error updating record');
                     FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERRITORIES_BIUD-Handler', 'Error updating record for updating terr' || sqlerrm);
            End;

        Else -- Changed_Terr_rec_Exist = 'False'
            -- New Territory Added
            -- TEST results:
            BEGIN
                INSERT INTO JTF_CHANGED_TERR
                    (terr_id, org_id, Action, Trigger_mode,
                    OLD_last_update_date, OLD_last_updated_by,
                    OLD_creation_date, OLD_created_by, OLD_last_update_login, OLD_start_date_active,
                    OLD_end_date_active, OLD_rank, OLD_update_flag, OLD_num_winners, OLD_parent_territory_id,
                    NEW_last_update_date, NEW_last_updated_by,
                    NEW_creation_date, NEW_created_by, NEW_last_update_login, NEW_start_date_active,
                    NEW_end_date_active, NEW_rank, NEW_update_flag, NEW_num_winners, NEW_parent_territory_id)
                values
                    (l_terr_id, p_org_id, 'NEW_RECORD', 'ON-UPDATE',
                    o_last_update_date, o_last_updated_by,
                    o_creation_date, o_created_by, o_last_update_login, o_start_date_active,
                    o_end_date_active, o_rank, o_update_flag, o_num_winners, o_parent_territory_id,
                    n_last_update_date, n_last_updated_by,
                    n_creation_date, n_created_by, n_last_update_login, n_start_date_active,
                    n_end_date_active, n_rank, n_update_flag, n_num_winners, n_parent_territory_id);
            EXCEPTION
                When OTHERS then
                    FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERRITORIES_BIUD-Handler', 'Error inserting record for updating terr' || sqlerrm);
                    null;
            End;
        End if;
    else -- Trigger_mode = 'ON-DELETE'
        -- check if we even have anything to delete.      -- Territory Deleted
        If Changed_Terr_rec_Exist = 'True' then
            -- This means that there exists either a INSERT or MODIFY changed_terr record.
            -- We delete this record of the INSERT or MODIFY, it is no longer needed
            BEGIN
                DELETE from JTF_CHANGED_TERR
                WHERE terr_id = l_terr_id
                    /* -- because we want to kill all records relating to this deleted territory
                    and terr_rsc_id is null
                    and terr_qtype_usg_id is null
                    and terr_rsc_access_id is null
                    and terr_value_id is null*/
                    and request_id is null;
            EXCEPTION
                When OTHERS then
                    null;
                    FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERRITORIES_BIUD-Handler', 'Error deleting record for deleting terr' || sqlerrm);
            End;
        Else -- Changed_Terr_rec_Exist = 'False'
            -- Now insert the jtf_changed_terr record documenting the deletion of this territory.
            BEGIN
                INSERT INTO JTF_CHANGED_TERR
                    (terr_id, org_id, Action, Trigger_mode, OLD_last_update_date, OLD_last_updated_by,
                    OLD_creation_date, OLD_created_by, OLD_last_update_login, OLD_start_date_active,
                    OLD_end_date_active, OLD_rank, OLD_update_flag, OLD_num_winners, OLD_parent_territory_id)
                values
                    (l_terr_id, p_org_id, 'NEW_RECORD', 'ON-DELETE', o_last_update_date, o_last_updated_by,
                    o_creation_date, o_created_by, o_last_update_login, o_start_date_active,
                    o_end_date_active, o_rank, o_update_flag, o_num_winners, o_parent_territory_id);
            EXCEPTION
                When OTHERS then
                    null;
                    FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERRITORIES_BIUD-Handler', 'Error inserting record for deleting terr' || sqlerrm);
                End;
        End if;
    End if;
EXCEPTION
    When NOT_SALES_TERR_CHANGE then
         null;
    When OTHERS then
         FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERRITORIES_BIUD-Handler', 'Problems: ' || sqlerrm);
        null;
END Territory_Trigger_Handler;

--**************************************************************
--  Terr_Values_Trigger_Handler
--**************************************************************
PROCEDURE Terr_Values_Trigger_Handler(
    P_TERR_VALUE_ID                     NUMBER,
    P_ORG_ID                            NUMBER,
    o_LAST_UPDATED_BY                   NUMBER,
    o_LAST_UPDATE_DATE                  DATE,
    o_CREATED_BY                        NUMBER,
    o_CREATION_DATE                     DATE,
    o_LAST_UPDATE_LOGIN                 NUMBER,
    o_TERR_QUAL_ID                      NUMBER,
    o_INCLUDE_FLAG                      VARCHAR2,
    o_COMPARISON_OPERATOR               VARCHAR2,
    o_ID_USED_FLAG                      VARCHAR2,
    o_LOW_VALUE_CHAR_ID                 NUMBER,
    o_LOW_VALUE_CHAR                    VARCHAR2,
    o_HIGH_VALUE_CHAR                   VARCHAR2,
    o_LOW_VALUE_NUMBER                  NUMBER,
    o_HIGH_VALUE_NUMBER                 NUMBER,
    o_VALUE_SET                         NUMBER,
    o_INTEREST_TYPE_ID                  NUMBER,
    o_PRIMARY_INTEREST_CODE_ID          NUMBER,
    o_SECONDARY_INTEREST_CODE_ID        NUMBER,
    o_CURRENCY_CODE                     VARCHAR2,
    n_LAST_UPDATED_BY                   NUMBER,
    n_LAST_UPDATE_DATE                  DATE,
    n_CREATED_BY                        NUMBER,
    n_CREATION_DATE                     DATE,
    n_LAST_UPDATE_LOGIN                 NUMBER,
    n_TERR_QUAL_ID                      NUMBER,
    n_INCLUDE_FLAG                      VARCHAR2,
    n_COMPARISON_OPERATOR               VARCHAR2,
    n_ID_USED_FLAG                      VARCHAR2,
    n_LOW_VALUE_CHAR_ID                 NUMBER,
    n_LOW_VALUE_CHAR                  	VARCHAR2,
    n_HIGH_VALUE_CHAR                 	VARCHAR2,
    n_LOW_VALUE_NUMBER                	NUMBER,
    n_HIGH_VALUE_NUMBER               	NUMBER,
    n_VALUE_SET                       	NUMBER,
    n_INTEREST_TYPE_ID                	NUMBER,
    n_PRIMARY_INTEREST_CODE_ID        	NUMBER,
    n_SECONDARY_INTEREST_CODE_ID      	NUMBER,
    n_CURRENCY_CODE                   	VARCHAR2,
    TRIGGER_MODE                      	VARCHAR2
    )
IS
    Changed_Terr_Value_Rec_Exists      	VARCHAR2(30);
    l_terr_id           		NUMBER;
    l_terr_qual_id      		NUMBER;
    l_terr_value_id     		NUMBER;
    l_seeded_qualifier_id 		NUMBER;
    exist_terr_id       		NUMBER;
    exist_terr_value_id 		NUMBER;
    l_source_id               NUMBER;
    NOT_SALES_TERR_CHANGE     exception;

BEGIN
    l_terr_id       := null;

    l_terr_value_id := p_terr_value_id;
    l_seeded_qualifier_id := l_seeded_qualifier_id;

    -- extracted terr_id, needed for jtf_changed_terr table
    If   TRIGGER_MODE = 'ON-DELETE' then
         l_terr_qual_id := o_TERR_QUAL_ID;
    Else
         l_terr_qual_id := n_TERR_QUAL_ID;
    End if;

    --dbms_output.put_line('JTDT- l_terr_qual_id = ' || l_terr_qual_id);
    --Get the territory_id for the values record
    BEGIN
        Select terr_id into l_terr_id
        from jtf_terr_qual where terr_qual_id = l_terr_qual_id;
    EXCEPTION
        WHEN NO_DATA_FOUND then
            --dbms_output.put_line('JTDT- No data found error with extracting terr_qual_id or terr_id: ' || sqlerrm);
            -- this should never happen since terr_qual_id req'd in jtf_terr_values
            -- and terr_id terr_qual_id required in jtf_terr_qual
            FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_VALUES_BIUD-Handler', 'terr_id does not exist for terr_value_id');
        WHEN OTHERS then
            --dbms_output.put_line('JTDT- Terr_val_trigger error with extracting terr_qual_id or terr_id: ' || sqlerrm);
            FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_VALUES_BIUD-Handler', 'Error while fetching terr_id from terr_value_id: ' || sqlerrm);

    End;
    -- check source of current territory
    -- only add / modify records in jtf_changed_terr all
    BEGIN
        --dbms_output.put_line('JTF_TERR_TRIGGER_HANDLER: (TERR_VAL)        terr_id = ' || l_terr_id);
        Select source_id into l_source_id
        from jtf_terr_usgs
        where terr_id = l_terr_id
              and source_id = -1001;
    EXCEPTION
        When NO_DATA_FOUND then
            --dbms_output.put_line('JTF_TERR_TRIGGER_HANDLER: (TERR_VAL)        NOT A SALES_TERR_CHANGE, raising exception ');
            raise NOT_SALES_TERR_CHANGE;
    End;
    --dbms_output.put_line('JTF_TERR_TRIGGER_HANDLER: (TERR_VAL)        SALES_TERR_CHANGE, updating changed terr table');

    --dbms_output.put_line('JTDT- l_terr_id = ' || l_terr_id);
    -- Check if CHANGED_TERR record already exists
    BEGIN
        Select terr_value_id into exist_terr_value_id
        from   JTF_CHANGED_TERR
        where   terr_rsc_id is null
                and terr_qtype_usg_id is null
                and terr_rsc_access_id is null
                and terr_id = l_terr_id
                and terr_value_id = l_terr_value_id
                and request_id is null;

        Changed_Terr_Value_Rec_Exists := 'True';
    EXCEPTION
        When NO_DATA_FOUND then
             exist_terr_value_id := NULL;
             Changed_Terr_Value_Rec_Exists := 'False';
            --dbms_output.put_line('JTDT- no data found in table: ' || sqlerrm);
        When OTHERS then
            null;
            --dbms_output.put_line('JTDT- error while looking for existing records: ' || sqlerrm);
            FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_VALUES_BIUD-Handler', 'Error testing for existing record: ' || sqlerrm);
    End;

    -- Extract the terr_id for this terr_value_id
    If Trigger_Mode = 'ON-INSERT' then
        If Changed_Terr_Value_Rec_Exists = 'True' then
            -- Update only -- This should never happen.
            null;
        else -- Changed_Terr_Value_Rec_Exists = 'False'
            -- Insert record
            BEGIN
                INSERT INTO JTF_CHANGED_TERR
                    (TERR_ID, TERR_VALUE_ID, ORG_ID, ACTION, TRIGGER_MODE,
                     OLD_LAST_UPDATED_BY, OLD_LAST_UPDATE_DATE, OLD_CREATED_BY, OLD_CREATION_DATE,
                     OLD_LAST_UPDATE_LOGIN, OLD_TERR_QUAL_ID, OLD_INCLUDE_FLAG, OLD_COMPARISON_OPERATOR,
                     OLD_ID_USED_FLAG, OLD_LOW_VALUE_CHAR_ID, OLD_LOW_VALUE_CHAR, OLD_HIGH_VALUE_CHAR,
                     OLD_LOW_VALUE_NUMBER, OLD_HIGH_VALUE_NUMBER, OLD_VALUE_SET, OLD_INTEREST_TYPE_ID,
                     OLD_PRIMARY_INTEREST_CODE_ID, OLD_SECONDARY_INTEREST_CODE_ID, OLD_CURRENCY_CODE,
                     NEW_LAST_UPDATED_BY, NEW_LAST_UPDATE_DATE, NEW_CREATED_BY, NEW_CREATION_DATE,
                     NEW_LAST_UPDATE_LOGIN, NEW_TERR_QUAL_ID, NEW_INCLUDE_FLAG, NEW_COMPARISON_OPERATOR,
                     NEW_ID_USED_FLAG, NEW_LOW_VALUE_CHAR_ID, NEW_LOW_VALUE_CHAR, NEW_HIGH_VALUE_CHAR,
                     NEW_LOW_VALUE_NUMBER, NEW_HIGH_VALUE_NUMBER, NEW_VALUE_SET, NEW_INTEREST_TYPE_ID,
                     NEW_PRIMARY_INTEREST_CODE_ID, NEW_SECONDARY_INTEREST_CODE_ID, NEW_CURRENCY_CODE)
                VALUES
                    (l_terr_id, l_terr_value_id, p_ORG_id, 'NEW_RECORD', 'ON-INSERT',
                     o_LAST_UPDATED_BY, o_LAST_UPDATE_DATE, o_CREATED_BY, o_CREATION_DATE,
                     o_LAST_UPDATE_LOGIN, o_TERR_QUAL_ID, o_INCLUDE_FLAG, o_COMPARISON_OPERATOR,
                     o_ID_USED_FLAG, o_LOW_VALUE_CHAR_ID, o_LOW_VALUE_CHAR, o_HIGH_VALUE_CHAR,
                     o_LOW_VALUE_NUMBER, o_HIGH_VALUE_NUMBER, o_VALUE_SET, o_INTEREST_TYPE_ID,
                     o_PRIMARY_INTEREST_CODE_ID, o_SECONDARY_INTEREST_CODE_ID, o_CURRENCY_CODE,
                     n_LAST_UPDATED_BY, n_LAST_UPDATE_DATE, n_CREATED_BY, n_CREATION_DATE,
                     n_LAST_UPDATE_LOGIN, n_TERR_QUAL_ID, n_INCLUDE_FLAG, n_COMPARISON_OPERATOR,
                     n_ID_USED_FLAG, n_LOW_VALUE_CHAR_ID, n_LOW_VALUE_CHAR, n_HIGH_VALUE_CHAR,
                     n_LOW_VALUE_NUMBER, n_HIGH_VALUE_NUMBER, n_VALUE_SET, n_INTEREST_TYPE_ID,
                     n_PRIMARY_INTEREST_CODE_ID, n_SECONDARY_INTEREST_CODE_ID, n_CURRENCY_CODE);
            EXCEPTION
                WHEN OTHERS THEN
                     --dbms_output.put_line('Failed at ON-INSERT, NEW_RECORD'|| sqlerrm);
                     FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_VALUES_BIUD-Handler', 'Error inserting record for inserting terr val' || sqlerrm);
            END;
        End if;
    elsif Trigger_mode = 'ON-UPDATE' then
        If  Changed_Terr_Value_Rec_Exists = 'True' then
            -- Update only
            BEGIN
                UPDATE JTF_CHANGED_TERR
                SET -- TERR_ID cannot be changed, as it is primary key
                    -- TERR_VALUE_ID                   = l_terr_value_id,
                    ACTION                          = 'UPDATED_RECORD',
                    TRIGGER_MODE                    = 'ON-UPDATE',
--                    OLD_LAST_UPDATED_BY             = o_LAST_UPDATED_BY,
--                    OLD_LAST_UPDATE_DATE            = o_LAST_UPDATE_DATE,
--                    OLD_CREATED_BY                  = o_CREATED_BY,
--                    OLD_CREATION_DATE               = o_CREATION_DATE,
--                    OLD_LAST_UPDATE_LOGIN           = o_LAST_UPDATE_LOGIN,
--                    OLD_TERR_QUAL_ID                = o_TERR_QUAL_ID,
--                    OLD_INCLUDE_FLAG                = o_INCLUDE_FLAG,
--                    OLD_COMPARISON_OPERATOR         = o_COMPARISON_OPERATOR,
--                    OLD_ID_USED_FLAG                = o_ID_USED_FLAG,
--                    OLD_LOW_VALUE_CHAR_ID           = o_LOW_VALUE_CHAR_ID,
--                    OLD_LOW_VALUE_CHAR              = o_LOW_VALUE_CHAR,
--                    OLD_HIGH_VALUE_CHAR             = o_HIGH_VALUE_CHAR,
--                    OLD_LOW_VALUE_NUMBER            = o_LOW_VALUE_NUMBER,
--                    OLD_HIGH_VALUE_NUMBER           = o_HIGH_VALUE_NUMBER,
--                    OLD_VALUE_SET                   = o_VALUE_SET,
--                    OLD_INTEREST_TYPE_ID            = o_INTEREST_TYPE_ID,
--                    OLD_PRIMARY_INTEREST_CODE_ID    = o_PRIMARY_INTEREST_CODE_ID,
--                    OLD_SECONDARY_INTEREST_CODE_ID  = o_SECONDARY_INTEREST_CODE_ID,
--                    OLD_CURRENCY_CODE               = o_CURRENCY_CODE,
                    NEW_LAST_UPDATED_BY             = n_LAST_UPDATED_BY,
                    NEW_LAST_UPDATE_DATE            = n_LAST_UPDATE_DATE,
                    NEW_CREATED_BY                  = n_CREATED_BY,
                    NEW_CREATION_DATE               = n_CREATION_DATE,
                    NEW_LAST_UPDATE_LOGIN           = n_LAST_UPDATE_LOGIN,
                    NEW_TERR_QUAL_ID                = n_TERR_QUAL_ID,
                    NEW_INCLUDE_FLAG                = n_INCLUDE_FLAG,
                    NEW_COMPARISON_OPERATOR         = n_COMPARISON_OPERATOR,
                    NEW_ID_USED_FLAG                = n_ID_USED_FLAG,
                    NEW_LOW_VALUE_CHAR_ID           = n_LOW_VALUE_CHAR_ID,
                    NEW_LOW_VALUE_CHAR              = n_LOW_VALUE_CHAR,
                    NEW_HIGH_VALUE_CHAR             = n_HIGH_VALUE_CHAR,
                    NEW_LOW_VALUE_NUMBER            = n_LOW_VALUE_NUMBER,
                    NEW_HIGH_VALUE_NUMBER           = n_HIGH_VALUE_NUMBER,
                    NEW_VALUE_SET                   = n_VALUE_SET,
                    NEW_INTEREST_TYPE_ID            = n_INTEREST_TYPE_ID,
                    NEW_PRIMARY_INTEREST_CODE_ID    = n_PRIMARY_INTEREST_CODE_ID,
                    NEW_SECONDARY_INTEREST_CODE_ID  = n_SECONDARY_INTEREST_CODE_ID,
                    NEW_CURRENCY_CODE               = n_CURRENCY_CODE
                WHERE terr_rsc_id is null
                    and terr_qtype_usg_id is null
                    and terr_rsc_access_id is null
                    and TERR_VALUE_ID = l_TERR_VALUE_ID
                    and TERR_ID = l_terr_id
                    and request_id is null;
            EXCEPTION
                WHEN OTHERS THEN
                     --dbms_output.put_line('Failed at ON-UPDATE, UPDATED_RECORD'|| sqlerrm);
                     FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_VALUES_BIUD-Handler', 'Error while updating record for updating terr val: ' || sqlerrm);
            END;
        else
            -- Changed_Terr_Value_Rec_Exists = 'False'
            -- Insert record
            BEGIN
                INSERT INTO JTF_CHANGED_TERR
                    (TERR_ID, TERR_VALUE_ID, ACTION, TRIGGER_MODE,
                    OLD_LAST_UPDATED_BY, OLD_LAST_UPDATE_DATE, OLD_CREATED_BY, OLD_CREATION_DATE,
                    OLD_LAST_UPDATE_LOGIN, OLD_TERR_QUAL_ID, OLD_INCLUDE_FLAG, OLD_COMPARISON_OPERATOR,
                    OLD_ID_USED_FLAG, OLD_LOW_VALUE_CHAR_ID, OLD_LOW_VALUE_CHAR, OLD_HIGH_VALUE_CHAR,
                    OLD_LOW_VALUE_NUMBER, OLD_HIGH_VALUE_NUMBER, OLD_VALUE_SET, OLD_INTEREST_TYPE_ID,
                    OLD_PRIMARY_INTEREST_CODE_ID, OLD_SECONDARY_INTEREST_CODE_ID, OLD_CURRENCY_CODE,
                    NEW_LAST_UPDATED_BY, NEW_LAST_UPDATE_DATE, NEW_CREATED_BY, NEW_CREATION_DATE,
                    NEW_LAST_UPDATE_LOGIN, NEW_TERR_QUAL_ID, NEW_INCLUDE_FLAG, NEW_COMPARISON_OPERATOR,
                    NEW_ID_USED_FLAG, NEW_LOW_VALUE_CHAR_ID, NEW_LOW_VALUE_CHAR, NEW_HIGH_VALUE_CHAR,
                    NEW_LOW_VALUE_NUMBER, NEW_HIGH_VALUE_NUMBER, NEW_VALUE_SET, NEW_INTEREST_TYPE_ID,
                    NEW_PRIMARY_INTEREST_CODE_ID, NEW_SECONDARY_INTEREST_CODE_ID, NEW_CURRENCY_CODE, ORG_ID)
                VALUES
                    (l_terr_id, l_terr_value_id,
                    'NEW_RECORD', 'ON-UPDATE',
                    o_LAST_UPDATED_BY, o_LAST_UPDATE_DATE, o_CREATED_BY, o_CREATION_DATE,
                    o_LAST_UPDATE_LOGIN, o_TERR_QUAL_ID, o_INCLUDE_FLAG, o_COMPARISON_OPERATOR,
                    o_ID_USED_FLAG, o_LOW_VALUE_CHAR_ID, o_LOW_VALUE_CHAR, o_HIGH_VALUE_CHAR,
                    o_LOW_VALUE_NUMBER, o_HIGH_VALUE_NUMBER, o_VALUE_SET, o_INTEREST_TYPE_ID,
                    o_PRIMARY_INTEREST_CODE_ID, o_SECONDARY_INTEREST_CODE_ID, o_CURRENCY_CODE,
                    n_LAST_UPDATED_BY, n_LAST_UPDATE_DATE, n_CREATED_BY, n_CREATION_DATE,
                    n_LAST_UPDATE_LOGIN, n_TERR_QUAL_ID, n_INCLUDE_FLAG, n_COMPARISON_OPERATOR,
                    n_ID_USED_FLAG, n_LOW_VALUE_CHAR_ID, n_LOW_VALUE_CHAR, n_HIGH_VALUE_CHAR,
                    n_LOW_VALUE_NUMBER, n_HIGH_VALUE_NUMBER, n_VALUE_SET, n_INTEREST_TYPE_ID,
                    n_PRIMARY_INTEREST_CODE_ID, n_SECONDARY_INTEREST_CODE_ID, n_CURRENCY_CODE, P_ORG_ID);
            EXCEPTION
                WHEN OTHERS THEN
                     --dbms_output.put_line('Failed at ON-UPDATE, NEW_RECORD'|| sqlerrm);
                     FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_VALUES_BIUD-Handler', 'Error while inserting record for updating terr val' || sqlerrm);
            END;
        End if;
    else
        -- Trigger_mode = 'ON-DELETE'
        If Changed_Terr_Value_Rec_Exists = 'True' then
            -- This means that there exists either a INSERT or MODIFY changed_terr record.
            -- We delete this record of the INSERT or MODIFY, it is no longer needed
            BEGIN
                DELETE from JTF_CHANGED_TERR
                WHERE terr_id = l_terr_id
                    and TERR_VALUE_ID = l_TERR_VALUE_ID
                    and terr_rsc_id is null
                    and terr_qtype_usg_id is null
                    and terr_rsc_access_id is null
                    and request_id is null;
            EXCEPTION
                When OTHERS then
                    null;
                    FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERRITORIES_BIUD-Handler', 'Error deleting record for deleting terr value' || sqlerrm);
            End;
        else -- Changed_Terr_Value_Rec_Exists = 'False'
            -- Insert record
            BEGIN
                INSERT INTO JTF_CHANGED_TERR
                    (TERR_ID, TERR_VALUE_ID, ACTION, TRIGGER_MODE,
                     OLD_LAST_UPDATED_BY, OLD_LAST_UPDATE_DATE, OLD_CREATED_BY, OLD_CREATION_DATE,
                     OLD_LAST_UPDATE_LOGIN, OLD_TERR_QUAL_ID, OLD_INCLUDE_FLAG, OLD_COMPARISON_OPERATOR,
                     OLD_ID_USED_FLAG, OLD_LOW_VALUE_CHAR_ID, OLD_LOW_VALUE_CHAR, OLD_HIGH_VALUE_CHAR,
                     OLD_LOW_VALUE_NUMBER, OLD_HIGH_VALUE_NUMBER, OLD_VALUE_SET, OLD_INTEREST_TYPE_ID,
                     OLD_PRIMARY_INTEREST_CODE_ID, OLD_SECONDARY_INTEREST_CODE_ID, OLD_CURRENCY_CODE,
                     NEW_LAST_UPDATED_BY, NEW_LAST_UPDATE_DATE, NEW_CREATED_BY, NEW_CREATION_DATE,
                     NEW_LAST_UPDATE_LOGIN, NEW_TERR_QUAL_ID, NEW_INCLUDE_FLAG, NEW_COMPARISON_OPERATOR,
                     NEW_ID_USED_FLAG, NEW_LOW_VALUE_CHAR_ID, NEW_LOW_VALUE_CHAR, NEW_HIGH_VALUE_CHAR,
                     NEW_LOW_VALUE_NUMBER, NEW_HIGH_VALUE_NUMBER, NEW_VALUE_SET, NEW_INTEREST_TYPE_ID,
                     NEW_PRIMARY_INTEREST_CODE_ID, NEW_SECONDARY_INTEREST_CODE_ID, NEW_CURRENCY_CODE, ORG_ID)
                VALUES
                    (l_terr_id, l_terr_value_id,
                     'NEW_RECORD', 'ON-DELETE',
                     o_LAST_UPDATED_BY, o_LAST_UPDATE_DATE, o_CREATED_BY, o_CREATION_DATE,
                     o_LAST_UPDATE_LOGIN, o_TERR_QUAL_ID, o_INCLUDE_FLAG, o_COMPARISON_OPERATOR,
                     o_ID_USED_FLAG, o_LOW_VALUE_CHAR_ID, o_LOW_VALUE_CHAR, o_HIGH_VALUE_CHAR,
                     o_LOW_VALUE_NUMBER, o_HIGH_VALUE_NUMBER, o_VALUE_SET, o_INTEREST_TYPE_ID,
                     o_PRIMARY_INTEREST_CODE_ID, o_SECONDARY_INTEREST_CODE_ID, o_CURRENCY_CODE,
                     n_LAST_UPDATED_BY, n_LAST_UPDATE_DATE, n_CREATED_BY, n_CREATION_DATE,
                     n_LAST_UPDATE_LOGIN, n_TERR_QUAL_ID, n_INCLUDE_FLAG, n_COMPARISON_OPERATOR,
                     n_ID_USED_FLAG, n_LOW_VALUE_CHAR_ID, n_LOW_VALUE_CHAR, n_HIGH_VALUE_CHAR,
                     n_LOW_VALUE_NUMBER, n_HIGH_VALUE_NUMBER, n_VALUE_SET, n_INTEREST_TYPE_ID,
                     n_PRIMARY_INTEREST_CODE_ID, n_SECONDARY_INTEREST_CODE_ID, n_CURRENCY_CODE, P_ORG_ID);
            EXCEPTION
                WHEN OTHERS THEN
                     --dbms_output.put_line('Failed at ON-DELETE, NEW_RECORD' || sqlerrm);
                     FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_VALUES_BIUD-Handler', 'Error while inserting record for deleting terr val ' || sqlerrm);
            END;
        End if;
    End if;
EXCEPTION
    When NOT_SALES_TERR_CHANGE then
         null;
    When OTHERS then
        FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_VALUES_BIUD-Handler', 'Problems: ' || sqlerrm);
        null;

END Terr_Values_Trigger_Handler;

--**************************************************************
--  Terr_Rsc_Trigger_Handler
--**************************************************************
PROCEDURE Terr_Rsc_Trigger_Handler(
    p_TERR_RSC_ID                       NUMBER,
    p_TERR_ID                           NUMBER,
    p_ORG_ID                            NUMBER,
    o_LAST_UPDATE_DATE                  DATE,
    o_LAST_UPDATED_BY                   NUMBER,
    o_CREATION_DATE                     DATE,
    o_CREATED_BY                        NUMBER,
    o_LAST_UPDATE_LOGIN                 NUMBER,
    o_RESOURCE_ID                       NUMBER,
    o_GROUP_ID                          NUMBER,
    o_RESOURCE_TYPE                     VARCHAR2,
    o_ROLE                              VARCHAR2,
    o_PRIMARY_CONTACT_FLAG              VARCHAR2,
    o_START_DATE_ACTIVE                 DATE,
    o_END_DATE_ACTIVE                   DATE,
    o_FULL_ACCESS_FLAG                  VARCHAR2,
    n_LAST_UPDATE_DATE                  DATE,
    n_LAST_UPDATED_BY                   NUMBER,
    n_CREATION_DATE                     DATE,
    n_CREATED_BY                        NUMBER,
    n_LAST_UPDATE_LOGIN                 NUMBER,
    n_RESOURCE_ID                       NUMBER,
    n_GROUP_ID                          NUMBER,
    n_RESOURCE_TYPE                     VARCHAR2,
    n_ROLE                              VARCHAR2,
    n_PRIMARY_CONTACT_FLAG              VARCHAR2,
    n_START_DATE_ACTIVE                 DATE,
    n_END_DATE_ACTIVE                   DATE,
    n_FULL_ACCESS_FLAG                  VARCHAR2,
    Trigger_Mode                        VARCHAR2
    )
IS
    l_terr_id           		    NUMBER;
    l_terr_rsc_id     		        NUMBER;
    Terr_Rsc_Rec_Exists             VARCHAR2(30);
    exist_terr_rsc_id 		        NUMBER;
    l_source_id               NUMBER;
    NOT_SALES_TERR_CHANGE     exception;


BEGIN
    l_terr_id                   := p_terr_id;
    l_terr_rsc_id               := p_terr_rsc_id;

    -- check source of current territory
    -- only add / modify records in jtf_changed_terr all
    BEGIN
        --dbms_output.put_line('JTF_TERR_TRIGGER_HANDLER: (TERR_RSC)        terr_id = ' || l_terr_id);
        Select source_id into l_source_id
        from jtf_terr_usgs
        where terr_id = l_terr_id
              and source_id = -1001;
    EXCEPTION
        When NO_DATA_FOUND then
            --dbms_output.put_line('JTF_TERR_TRIGGER_HANDLER: (TERR_RSC)        NOT A SALES_TERR_CHANGE, raising exception ');
            raise NOT_SALES_TERR_CHANGE;
    End;
    --dbms_output.put_line('JTF_TERR_TRIGGER_HANDLER: (TERR_RSC)        SALES_TERR_CHANGE, updating changed terr table');

    -- check if terr_rsc record exists
    BEGIN
        Select terr_rsc_id into exist_terr_rsc_id
        from   JTF_CHANGED_TERR
        where   terr_value_id is null
                and terr_qtype_usg_id is null
                and terr_rsc_access_id is null
                and terr_rsc_id = l_terr_rsc_id
                and Terr_id = l_terr_id
                and request_id is null;
        Terr_Rsc_Rec_Exists := 'True';
    EXCEPTION
        When NO_DATA_FOUND then
            exist_terr_rsc_id := NULL;
            Terr_Rsc_Rec_Exists := 'False';
        When OTHERS then
            FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_RSC_BIUD-Handler', 'Error testing for existing record: ' || sqlerrm);
    End;

    If Trigger_Mode = 'ON-INSERT' then
        If Terr_Rsc_Rec_Exists = 'True' then
            -- Update only -- This should never happen.
            null;
        else -- Changed_Terr_Value_Rec_Exists = 'False'
            -- Insert record
            BEGIN
                INSERT INTO JTF_CHANGED_TERR
                    (TERR_ID, TERR_RSC_ID, ORG_ID, ACTION, TRIGGER_MODE,
                    OLD_LAST_UPDATE_DATE, OLD_LAST_UPDATED_BY, OLD_CREATION_DATE, OLD_CREATED_BY,
                    OLD_LAST_UPDATE_LOGIN, OLD_RESOURCE_ID, OLD_GROUP_ID, OLD_RESOURCE_TYPE,
                    OLD_ROLE, OLD_PRIMARY_CONTACT_FLAG, OLD_START_DATE_ACTIVE, OLD_END_DATE_ACTIVE,
                    OLD_FULL_ACCESS_FLAG, NEW_LAST_UPDATE_DATE, NEW_LAST_UPDATED_BY, NEW_CREATION_DATE,
                    NEW_CREATED_BY, NEW_LAST_UPDATE_LOGIN, NEW_RESOURCE_ID, NEW_GROUP_ID,
                    NEW_RESOURCE_TYPE, NEW_ROLE, NEW_PRIMARY_CONTACT_FLAG, NEW_START_DATE_ACTIVE,
                    NEW_END_DATE_ACTIVE, NEW_FULL_ACCESS_FLAG)
                VALUES
                    (l_terr_id, l_terr_rsc_id, p_ORG_ID, 'NEW_RECORD', 'ON-INSERT',
                    o_LAST_UPDATE_DATE, o_LAST_UPDATED_BY, o_CREATION_DATE, o_CREATED_BY,
                    o_LAST_UPDATE_LOGIN, o_RESOURCE_ID, o_RESOURCE_TYPE, o_GROUP_ID,
                    o_ROLE, o_PRIMARY_CONTACT_FLAG, o_START_DATE_ACTIVE, o_END_DATE_ACTIVE,
                    o_FULL_ACCESS_FLAG, n_LAST_UPDATE_DATE, n_LAST_UPDATED_BY, n_CREATION_DATE,
                    n_CREATED_BY, n_LAST_UPDATE_LOGIN, n_RESOURCE_ID, n_GROUP_ID, n_RESOURCE_TYPE,
                    n_ROLE, n_PRIMARY_CONTACT_FLAG, n_START_DATE_ACTIVE,
                    n_END_DATE_ACTIVE, n_FULL_ACCESS_FLAG);
                --dbms_output.put_line('JTF_TERR_RSC_BIUD-Handler Success: ON-INSERT, NEW_RECORD'|| sqlerrm);
            EXCEPTION
                WHEN OTHERS THEN
                     FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_RSC_BIUD-Handler', 'Error inserting record for inserting terr rsc' || sqlerrm);
            END;
        End if;
    elsif Trigger_mode = 'ON-UPDATE' then
        If Terr_Rsc_Rec_Exists = 'True' then
            -- Update only
            BEGIN
                UPDATE JTF_CHANGED_TERR
                SET
                    -- TERR_RSC_ID                 = l_terr_rsc_id,
                    ACTION                      = 'UPDATED_RECORD',
                    Trigger_Mode                = 'ON-UPDATE',
--                    OLD_LAST_UPDATE_DATE        = o_LAST_UPDATE_DATE,
--                    OLD_LAST_UPDATED_BY         = o_LAST_UPDATED_BY,
--                    OLD_CREATION_DATE           = o_CREATION_DATE,
--                    OLD_CREATED_BY              = o_CREATED_BY,
--                    OLD_LAST_UPDATE_LOGIN       = o_LAST_UPDATE_LOGIN,
--                    OLD_RESOURCE_ID             = o_RESOURCE_ID,
--                    OLD_GROUP_ID                = o_GROUP_ID,
--                    OLD_RESOURCE_TYPE           = o_RESOURCE_TYPE,
--                    OLD_ROLE                    = o_ROLE,
--                    OLD_PRIMARY_CONTACT_FLAG    = o_PRIMARY_CONTACT_FLAG,
--                    OLD_START_DATE_ACTIVE       = o_START_DATE_ACTIVE,
--                    OLD_END_DATE_ACTIVE         = o_END_DATE_ACTIVE,
--                    OLD_FULL_ACCESS_FLAG        = o_FULL_ACCESS_FLAG,
                    NEW_LAST_UPDATE_DATE        = n_LAST_UPDATE_DATE,
                    NEW_LAST_UPDATED_BY         = n_LAST_UPDATED_BY,
                    NEW_CREATION_DATE           = n_CREATION_DATE,
                    NEW_CREATED_BY              = n_CREATED_BY,
                    NEW_LAST_UPDATE_LOGIN       = n_LAST_UPDATE_LOGIN,
                    NEW_RESOURCE_ID             = n_RESOURCE_ID,
                    NEW_GROUP_ID                = n_GROUP_ID,
                    NEW_RESOURCE_TYPE           = n_RESOURCE_TYPE,
                    NEW_ROLE                    = n_ROLE,
                    NEW_PRIMARY_CONTACT_FLAG    = n_PRIMARY_CONTACT_FLAG,
                    NEW_START_DATE_ACTIVE       = n_START_DATE_ACTIVE,
                    NEW_END_DATE_ACTIVE         = n_END_DATE_ACTIVE,
                    NEW_FULL_ACCESS_FLAG        = n_FULL_ACCESS_FLAG
                WHERE terr_qtype_usg_id is null
                    and terr_rsc_access_id is null
                    and terr_value_id is null
                    and TERR_RSC_ID = l_terr_rsc_id
                    and terr_id = l_terr_id
                    and request_id is null;
            EXCEPTION
                WHEN OTHERS THEN
                     FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_RSC_BIUD-Handler', 'Error while updating record for updating terr rsc: ' || sqlerrm);
            END;
        else
            -- Changed_Terr_Value_Rec_Exists = 'False'
            -- Insert record
            BEGIN
                INSERT INTO JTF_CHANGED_TERR
                    (TERR_ID, TERR_RSC_ID, ORG_ID, ACTION, TRIGGER_MODE,
                    OLD_LAST_UPDATE_DATE, OLD_LAST_UPDATED_BY, OLD_CREATION_DATE, OLD_CREATED_BY,
                    OLD_LAST_UPDATE_LOGIN, OLD_RESOURCE_ID, OLD_GROUP_ID, OLD_RESOURCE_TYPE,
                    OLD_ROLE, OLD_PRIMARY_CONTACT_FLAG, OLD_START_DATE_ACTIVE, OLD_END_DATE_ACTIVE,
                    OLD_FULL_ACCESS_FLAG, NEW_LAST_UPDATE_DATE, NEW_LAST_UPDATED_BY, NEW_CREATION_DATE,
                    NEW_CREATED_BY, NEW_LAST_UPDATE_LOGIN, NEW_RESOURCE_ID, NEW_GROUP_ID,
                    NEW_RESOURCE_TYPE, NEW_ROLE, NEW_PRIMARY_CONTACT_FLAG, NEW_START_DATE_ACTIVE,
                    NEW_END_DATE_ACTIVE, NEW_FULL_ACCESS_FLAG)
                VALUES
                    (l_terr_id, l_terr_rsc_id, p_ORG_ID, 'NEW_RECORD', 'ON-UPDATE',
                    o_LAST_UPDATE_DATE, o_LAST_UPDATED_BY, o_CREATION_DATE, o_CREATED_BY,
                    o_LAST_UPDATE_LOGIN, o_RESOURCE_ID, o_GROUP_ID, o_RESOURCE_TYPE, o_ROLE,
                    o_PRIMARY_CONTACT_FLAG, o_START_DATE_ACTIVE, o_END_DATE_ACTIVE, o_FULL_ACCESS_FLAG,
                    n_LAST_UPDATE_DATE, n_LAST_UPDATED_BY, n_CREATION_DATE, n_CREATED_BY,
                    n_LAST_UPDATE_LOGIN, n_RESOURCE_ID, n_GROUP_ID, n_RESOURCE_TYPE,
                    n_ROLE, n_PRIMARY_CONTACT_FLAG, n_START_DATE_ACTIVE, n_END_DATE_ACTIVE,
                    n_FULL_ACCESS_FLAG);
            EXCEPTION
                WHEN OTHERS THEN
                    FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_RSC_BIUD-Handler', 'Error while inserting record for updating terr rsc' || sqlerrm);
            END;
        End if;
    else -- Trigger_mode = 'ON-DELETE'
        If Terr_Rsc_Rec_Exists = 'True' then
            BEGIN
                DELETE from JTF_CHANGED_TERR
                WHERE terr_id = l_terr_id
                    and TERR_RSC_ID = l_terr_rsc_id
                    and TERR_VALUE_ID is null
                    and terr_qtype_usg_id is null
                    and terr_rsc_access_id is null
                    and request_id is null;
            EXCEPTION
                When OTHERS then
                    null;
                    FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERRITORIES_BIUD-Handler', 'Error deleting record for deleting terr rsc' || sqlerrm);
            End;
        else -- Changed_Terr_Value_Rec_Exists = 'False'
            BEGIN
                INSERT INTO JTF_CHANGED_TERR
                    (TERR_ID, TERR_RSC_ID, ORG_ID, ACTION, TRIGGER_MODE,
                    OLD_LAST_UPDATE_DATE, OLD_LAST_UPDATED_BY, OLD_CREATION_DATE, OLD_CREATED_BY,
                    OLD_LAST_UPDATE_LOGIN, OLD_RESOURCE_ID, OLD_GROUP_ID, OLD_RESOURCE_TYPE,
                    OLD_ROLE, OLD_PRIMARY_CONTACT_FLAG, OLD_START_DATE_ACTIVE, OLD_END_DATE_ACTIVE,
                    OLD_FULL_ACCESS_FLAG, NEW_LAST_UPDATE_DATE, NEW_LAST_UPDATED_BY, NEW_CREATION_DATE,
                    NEW_CREATED_BY, NEW_LAST_UPDATE_LOGIN, NEW_RESOURCE_ID, NEW_GROUP_ID,
                    NEW_RESOURCE_TYPE, NEW_ROLE, NEW_PRIMARY_CONTACT_FLAG, NEW_START_DATE_ACTIVE,
                    NEW_END_DATE_ACTIVE, NEW_FULL_ACCESS_FLAG)
                VALUES
                    (l_terr_id, l_terr_rsc_id, p_ORG_ID, 'NEW_RECORD', 'ON-DELETE',
                    o_LAST_UPDATE_DATE, o_LAST_UPDATED_BY, o_CREATION_DATE, o_CREATED_BY,
                    o_LAST_UPDATE_LOGIN, o_RESOURCE_ID, o_GROUP_ID, o_RESOURCE_TYPE,
                    o_ROLE, o_PRIMARY_CONTACT_FLAG, o_START_DATE_ACTIVE, o_END_DATE_ACTIVE,
                    o_FULL_ACCESS_FLAG, n_LAST_UPDATE_DATE, n_LAST_UPDATED_BY, n_CREATION_DATE,
                    n_CREATED_BY, n_LAST_UPDATE_LOGIN, n_RESOURCE_ID, n_GROUP_ID,
                    n_RESOURCE_TYPE, n_ROLE, n_PRIMARY_CONTACT_FLAG, n_START_DATE_ACTIVE,
                    n_END_DATE_ACTIVE, n_FULL_ACCESS_FLAG);
            EXCEPTION
                WHEN OTHERS THEN
                    FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_RSC_BIUD-Handler', 'Error while inserting record for deleting terr rsc ' || sqlerrm);
            END;
        End if;

    End if;
EXCEPTION
    When NOT_SALES_TERR_CHANGE then
         null;
    When OTHERS then
        FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_RSC_BIUD-Handler', 'Problems: ' || sqlerrm);
        null;

END Terr_Rsc_Trigger_Handler;

--**************************************************************
--  Terr_QType_Trigger_Handler
--**************************************************************

PROCEDURE Terr_QType_Trigger_Handler(
    p_terr_qtype_usg_id                 NUMBER,
    p_terr_id                           NUMBER,
    p_org_id                            NUMBER,
    o_LAST_UPDATED_BY                   NUMBER,
    o_LAST_UPDATE_DATE                  DATE,
    o_CREATED_BY                        NUMBER,
    o_CREATION_DATE                     DATE,
    o_LAST_UPDATE_LOGIN                 NUMBER,
    n_LAST_UPDATED_BY                   NUMBER,
    n_LAST_UPDATE_DATE                  DATE,
    n_CREATED_BY                        NUMBER,
    n_CREATION_DATE                     DATE,
    n_LAST_UPDATE_LOGIN                 NUMBER,
    o_qual_type_usg_id                  NUMBER,
    n_qual_type_usg_id                  NUMBER,
    Trigger_Mode                        VARCHAR2
    )
IS
    Changed_Terr_QType_Rec_Exists      	VARCHAR2(30);
    l_terr_id           		NUMBER;
    l_terr_qtype_usg_id      	NUMBER;
    exist_terr_id       		NUMBER;
    exist_terr_qtype_id 		NUMBER;
    l_source_id               NUMBER;
    NOT_SALES_TERR_CHANGE     exception;


BEGIN
    --dbms_output.put_line('Terr_QType_Trigger_Handler: BEGIN');

    l_terr_id       := p_terr_id;
    l_terr_qtype_usg_id := p_terr_qtype_usg_id;

    -- check source of current territory
    -- only add / modify records in jtf_changed_terr all
    BEGIN
        --dbms_output.put_line('JTF_TERR_TRIGGER_HANDLER: (TERR_QTYPE)      terr_id = ' || l_terr_id);
        Select source_id into l_source_id
        from jtf_terr_usgs
        where terr_id = l_terr_id
              and source_id = -1001;
    EXCEPTION
        When NO_DATA_FOUND then
            --dbms_output.put_line('JTF_TERR_TRIGGER_HANDLER: (TERR_QTYPE)      NOT A SALES_TERR_CHANGE, raising exception ');
            raise NOT_SALES_TERR_CHANGE;
    End;
    --dbms_output.put_line('JTF_TERR_TRIGGER_HANDLER: (TERR_QTYPE)      SALES_TERR_CHANGE, updating changed terr table');


    -- Check if record already exists in changed_terr table
    BEGIN
        Select terr_qtype_usg_id into exist_terr_qtype_id
        from   JTF_CHANGED_TERR
        where   terr_value_id is null
                and terr_rsc_id is null
                and terr_rsc_access_id is null
                and terr_qtype_usg_id = l_terr_qtype_usg_id
                and terr_id = l_terr_id
                and request_id is null;

        Changed_Terr_QType_Rec_Exists := 'True';
    EXCEPTION
        When NO_DATA_FOUND then
             exist_terr_qtype_id := NULL;
             Changed_Terr_QType_Rec_Exists := 'False';
            --dbms_output.put_line('JTDT- no data found in table: ' || sqlerrm);
        When OTHERS then
            null;
            --dbms_output.put_line('JTDT- error while looking for existing records: ' || sqlerrm);
            FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_QTYPE_USGS_BIUD-Handler', 'Error testing for existing record: ' || sqlerrm);
    End;

    -- Extract the terr_id for this terr_value_id
    If Trigger_Mode = 'ON-INSERT' then
        If Changed_Terr_QType_Rec_Exists = 'True' then
            -- Update only -- This should never happen.
            null;
        else -- Changed_Terr_Value_Rec_Exists = 'False'
            -- Insert record
            BEGIN
                INSERT INTO JTF_CHANGED_TERR
                    (TERR_ID, TERR_QTYPE_USG_ID, ORG_ID, ACTION, TRIGGER_MODE,
                    OLD_LAST_UPDATE_DATE, OLD_LAST_UPDATED_BY, OLD_CREATION_DATE, OLD_CREATED_BY, OLD_LAST_UPDATE_LOGIN,
                    NEW_LAST_UPDATE_DATE, NEW_LAST_UPDATED_BY, NEW_CREATION_DATE, NEW_CREATED_BY, NEW_LAST_UPDATE_LOGIN,
                    OLD_qual_type_usg_id, NEW_qual_type_usg_id)
                VALUES
                    (l_terr_id, l_terr_qtype_usg_id, p_org_id, 'NEW_RECORD', 'ON-INSERT',
                    o_LAST_UPDATE_DATE, o_LAST_UPDATED_BY, o_CREATION_DATE, o_CREATED_BY, o_LAST_UPDATE_LOGIN,
                    n_LAST_UPDATE_DATE, n_LAST_UPDATED_BY, n_CREATION_DATE, n_CREATED_BY, n_LAST_UPDATE_LOGIN,
                    o_qual_type_usg_id, n_qual_type_usg_id);

            EXCEPTION
                WHEN OTHERS THEN
                     --dbms_output.put_line('Failed at ON-INSERT, NEW_RECORD'|| sqlerrm);
                     FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_QTYPE_USGS_BIUD-Handler', 'Error inserting record for inserting terr qtype' || sqlerrm);
            END;
        End if;
    elsif Trigger_mode = 'ON-UPDATE' then
        If  Changed_Terr_QType_Rec_Exists = 'True' then
            -- Update only
            BEGIN
                UPDATE JTF_CHANGED_TERR
                SET -- TERR_ID cannot be changed, as it is primary key
                    --TERR_QTYPE_USG_ID           = l_terr_qtype_usg_id,
                    ACTION                      = 'UPDATED_RECORD',
                    Trigger_Mode                = 'ON-UPDATE',
--                    OLD_LAST_UPDATE_DATE        = o_LAST_UPDATE_DATE,
--                    OLD_LAST_UPDATED_BY         = o_LAST_UPDATED_BY,
--                    OLD_CREATION_DATE           = o_CREATION_DATE,
--                    OLD_CREATED_BY              = o_CREATED_BY,
--                    OLD_LAST_UPDATE_LOGIN       = o_LAST_UPDATE_LOGIN,
                    NEW_LAST_UPDATE_DATE        = n_LAST_UPDATE_DATE,
                    NEW_LAST_UPDATED_BY         = n_LAST_UPDATED_BY,
                    NEW_CREATION_DATE           = n_CREATION_DATE,
                    NEW_CREATED_BY              = n_CREATED_BY,
                    NEW_LAST_UPDATE_LOGIN       = n_LAST_UPDATE_LOGIN,
                    OLD_qual_type_usg_id        = o_qual_type_usg_id,
                    NEW_qual_type_usg_id        = n_qual_type_usg_id
                WHERE terr_rsc_id is null
                    and terr_rsc_access_id is null
                    and terr_value_id is null
                    and terr_qtype_usg_id = l_terr_qtype_usg_id
                    and terr_id = l_terr_id
                    and request_id is null;
            EXCEPTION
                WHEN OTHERS THEN
                     --dbms_output.put_line('Failed at ON-UPDATE, UPDATED_RECORD'|| sqlerrm);
                     FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_QTYPE_USGS_BIUD-Handler', 'Error while updating record for updating terr qtype: ' || sqlerrm);
            END;
        else
            -- Changed_Terr_Value_Rec_Exists = 'False'
            -- Insert record
            BEGIN
                INSERT INTO JTF_CHANGED_TERR
                    (TERR_ID, TERR_QTYPE_USG_ID, ORG_ID, ACTION, TRIGGER_MODE,
                    OLD_LAST_UPDATE_DATE, OLD_LAST_UPDATED_BY, OLD_CREATION_DATE, OLD_CREATED_BY, OLD_LAST_UPDATE_LOGIN,
                    NEW_LAST_UPDATE_DATE, NEW_LAST_UPDATED_BY, NEW_CREATION_DATE, NEW_CREATED_BY, NEW_LAST_UPDATE_LOGIN,
                    OLD_qual_type_usg_id, NEW_qual_type_usg_id)
                VALUES
                    (l_terr_id, l_terr_qtype_usg_id, p_org_id, 'NEW_RECORD', 'ON-UPDATE',
                    o_LAST_UPDATE_DATE, o_LAST_UPDATED_BY, o_CREATION_DATE, o_CREATED_BY, o_LAST_UPDATE_LOGIN,
                    n_LAST_UPDATE_DATE, n_LAST_UPDATED_BY, n_CREATION_DATE, n_CREATED_BY, n_LAST_UPDATE_LOGIN,
                    o_qual_type_usg_id, n_qual_type_usg_id);
            EXCEPTION
                WHEN OTHERS THEN
                     --dbms_output.put_line('Failed at ON-UPDATE, NEW_RECORD'|| sqlerrm);
                     FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_QTYPE_USGS_BIUD-Handler', 'Error while inserting record for updating terr qtype: ' || sqlerrm);
            END;
        End if;
    else
        -- Trigger_mode = 'ON-DELETE'
        If Changed_Terr_QType_Rec_Exists = 'True' then
            BEGIN
                DELETE from JTF_CHANGED_TERR
                WHERE terr_id = l_terr_id
                    and terr_qtype_usg_id = l_terr_qtype_usg_id
                    and TERR_RSC_ID is null
                    and TERR_VALUE_ID is null
                    and terr_rsc_access_id is null
                    and terr_value_id is null
                    and request_id is null;
            EXCEPTION
                When OTHERS then
                    null;
                    FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERRITORIES_BIUD-Handler', 'Error deleting record for deleting terr rsc' || sqlerrm);
            End;
        else -- Changed_Terr_Value_Rec_Exists = 'False'
            BEGIN
                INSERT INTO JTF_CHANGED_TERR
                    (TERR_ID, TERR_QTYPE_USG_ID, ORG_ID, ACTION, TRIGGER_MODE,
                    OLD_LAST_UPDATE_DATE, OLD_LAST_UPDATED_BY, OLD_CREATION_DATE, OLD_CREATED_BY, OLD_LAST_UPDATE_LOGIN,
                    NEW_LAST_UPDATE_DATE, NEW_LAST_UPDATED_BY, NEW_CREATION_DATE, NEW_CREATED_BY, NEW_LAST_UPDATE_LOGIN,
                    OLD_qual_type_usg_id, NEW_qual_type_usg_id)
                VALUES
                    (l_terr_id, l_terr_qtype_usg_id, p_org_id, 'NEW_RECORD', 'ON-DELETE',
                    o_LAST_UPDATE_DATE, o_LAST_UPDATED_BY, o_CREATION_DATE, o_CREATED_BY, o_LAST_UPDATE_LOGIN,
                    n_LAST_UPDATE_DATE, n_LAST_UPDATED_BY, n_CREATION_DATE, n_CREATED_BY, n_LAST_UPDATE_LOGIN,
                    o_qual_type_usg_id, n_qual_type_usg_id);
            EXCEPTION
                WHEN OTHERS THEN
                     --dbms_output.put_line('Failed at ON-DELETE, NEW_RECORD' || sqlerrm);
                     FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_QTYPE_USGS_BIUD-Handler', 'Error while inserting record for deleting terr qtype: ' || sqlerrm);
            END;
        End if;
    End if;
EXCEPTION
    When NOT_SALES_TERR_CHANGE then
         null;
    When OTHERS then
        FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_QTYPE_BIUD-Handler', 'Problems: ' || sqlerrm);
        null;

END Terr_QType_Trigger_Handler;

--**************************************************************
--  Terr_RscAccess_Trigger_Handler
--**************************************************************
PROCEDURE Terr_RscAccess_Trigger_Handler(
    p_terr_rsc_access_id                NUMBER,
    p_terr_rsc_id                       NUMBER,
    p_org_id                            NUMBER,
    o_LAST_UPDATED_BY                   NUMBER,
    o_LAST_UPDATE_DATE                  DATE,
    o_CREATED_BY                        NUMBER,
    o_CREATION_DATE                     DATE,
    o_LAST_UPDATE_LOGIN                 NUMBER,
    n_LAST_UPDATED_BY                   NUMBER,
    n_LAST_UPDATE_DATE                  DATE,
    n_CREATED_BY                        NUMBER,
    n_CREATION_DATE                     DATE,
    n_LAST_UPDATE_LOGIN                 NUMBER,
    o_access_type                       VARCHAR2,
    n_access_type                       VARCHAR2,
    Trigger_Mode                        VARCHAR2
    )
IS
    Changed_Terr_RscAcc_Rec_Exists      VARCHAR2(30);
    l_terr_id                           NUMBER;
    l_terr_rsc_id                       NUMBER;
    l_terr_rsc_access_id                NUMBER;
    exist_terr_id                       NUMBER;
    exist_terr_rscaccess_id             NUMBER;
    l_source_id               NUMBER;
    NOT_SALES_TERR_CHANGE     exception;

BEGIN
    null;

    l_terr_id       := null;
    l_terr_rsc_id       := p_terr_rsc_id;
    l_terr_rsc_access_id := p_terr_rsc_access_id;

    --dbms_output.put_line('Terr_RscAccess_Trigger_Handler: BEGIN');
    --Get the territory_id for this record
    BEGIN
        Select terr_id into l_terr_id
        from    jtf_terr_rsc
        where   terr_rsc_id = l_terr_rsc_id;
    EXCEPTION
        WHEN NO_DATA_FOUND then
            FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_RSC_ACCESS_BIUD-Handler', 'terr_id does not exist for terr_rsc_access_id');
        WHEN OTHERS then
            FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_RSC_ACCESS_BIUD-Handler', 'Error while fetching terr_id from terr_rsc_access_id: ' || sqlerrm);
    End;

    -- check source of current territory
    -- only add / modify records in jtf_changed_terr all
    BEGIN
        --dbms_output.put_line('JTF_TERR_TRIGGER_HANDLER: (TERR_RSC_ACCESS) terr_id = ' || l_terr_id);
        Select source_id into l_source_id
        from jtf_terr_usgs
        where terr_id = l_terr_id
              and source_id = -1001;
    EXCEPTION
        When NO_DATA_FOUND then
            --dbms_output.put_line('JTF_TERR_TRIGGER_HANDLER: (TERR_RSC_ACCESS) NOT A SALES_TERR_CHANGE, raising exception ');
            raise NOT_SALES_TERR_CHANGE;
    End;
    --dbms_output.put_line('JTF_TERR_TRIGGER_HANDLER: (TERR_RSC_ACCESS) SALES_TERR_CHANGE, updating changed terr table');

    --dbms_output.put_line('JTDT- l_terr_id = ' || l_terr_id);
    -- Check if record already exists in changed_terr table
    BEGIN
        Select terr_rsc_access_id into l_terr_rsc_access_id
        from   JTF_CHANGED_TERR
        where   terr_value_id is null
                and terr_rsc_id is null
                and terr_qtype_usg_id is null
                and terr_rsc_access_id = l_terr_rsc_access_id
                and terr_id = l_terr_id
                and request_id is null;

        Changed_Terr_RscAcc_Rec_Exists := 'True';
    EXCEPTION
        When NO_DATA_FOUND then
             exist_terr_rscaccess_id := NULL;
             Changed_Terr_RscAcc_Rec_Exists := 'False';
            --dbms_output.put_line('JTDT- no data found in table: ' || sqlerrm);
        When OTHERS then
            null;
            --dbms_output.put_line('JTDT- error while looking for existing records: ' || sqlerrm);
            FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_RSC_ACCESS_BIUD-Handler', 'Error testing for existing record: ' || sqlerrm);
    End;

    -- Extract the terr_id for this terr_value_id
    If Trigger_Mode = 'ON-INSERT' then
        If Changed_Terr_RscAcc_Rec_Exists = 'True' then
            -- Update only -- This should never happen.
            null;
        else -- Changed_Terr_RscAccess_Rec_Exists = 'False'
            -- Insert record
            BEGIN
                INSERT INTO JTF_CHANGED_TERR
                    (TERR_ID, TERR_RSC_ACCESS_ID, ORG_ID, ACTION, TRIGGER_MODE,
                    OLD_LAST_UPDATE_DATE, OLD_LAST_UPDATED_BY, OLD_CREATION_DATE, OLD_CREATED_BY, OLD_LAST_UPDATE_LOGIN,
                    NEW_LAST_UPDATE_DATE, NEW_LAST_UPDATED_BY, NEW_CREATION_DATE, NEW_CREATED_BY, NEW_LAST_UPDATE_LOGIN,
                    OLD_ACCESS_TYPE, NEW_ACCESS_TYPE)
                VALUES
                    (l_terr_id, l_terr_rsc_access_id, p_org_id, 'NEW_RECORD', 'ON-INSERT',
                    o_LAST_UPDATE_DATE, o_LAST_UPDATED_BY, o_CREATION_DATE, o_CREATED_BY, o_LAST_UPDATE_LOGIN,
                    n_LAST_UPDATE_DATE, n_LAST_UPDATED_BY, n_CREATION_DATE, n_CREATED_BY, n_LAST_UPDATE_LOGIN,
                    o_access_type, n_access_type);

            EXCEPTION
                WHEN OTHERS THEN
                     --dbms_output.put_line('Failed at ON-INSERT, NEW_RECORD'|| sqlerrm);
                     FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_RSC_ACCESS_BIUD-Handler', 'Error inserting record for inserting rsc access' || sqlerrm);
            END;
        End if;
    elsif Trigger_mode = 'ON-UPDATE' then
        If  Changed_Terr_RscAcc_Rec_Exists = 'True' then
            -- Update only
            BEGIN
                UPDATE JTF_CHANGED_TERR
                SET -- TERR_ID cannot be changed, as it is primary key
                    --TERR_RSC_ACCESS_ID          = l_terr_rsc_access_id,
                    ACTION                      = 'UPDATED_RECORD',
                    Trigger_Mode                = 'ON-UPDATE',
--                    OLD_LAST_UPDATE_DATE        = o_LAST_UPDATE_DATE,
--                    OLD_LAST_UPDATED_BY         = o_LAST_UPDATED_BY,
--                    OLD_CREATION_DATE           = o_CREATION_DATE,
--                    OLD_CREATED_BY              = o_CREATED_BY,
--                    OLD_LAST_UPDATE_LOGIN       = o_LAST_UPDATE_LOGIN,
                    NEW_LAST_UPDATE_DATE        = n_LAST_UPDATE_DATE,
                    NEW_LAST_UPDATED_BY         = n_LAST_UPDATED_BY,
                    NEW_CREATION_DATE           = n_CREATION_DATE,
                    NEW_CREATED_BY              = n_CREATED_BY,
                    NEW_LAST_UPDATE_LOGIN       = n_LAST_UPDATE_LOGIN,
                    OLD_ACCESS_TYPE             = o_access_type,
                    NEW_ACCESS_TYPE             = n_access_type
                WHERE terr_rsc_id is null
                    and terr_qtype_usg_id is null
                    and terr_value_id is null
                    and terr_rsc_access_id = l_terr_rsc_access_id
                    and terr_id = l_terr_id
                    and request_id is null;
            EXCEPTION
                WHEN OTHERS THEN
                     --dbms_output.put_line('Failed at ON-UPDATE, UPDATED_RECORD'|| sqlerrm);
                     FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_RSC_ACCESS_BIUD-Handler', 'Error while updating record for updating rsc access: ' || sqlerrm);
            END;
        else
            -- Changed_Terr_RscAccess_Rec_Exists = 'False'
            -- Insert record
            BEGIN
                INSERT INTO JTF_CHANGED_TERR
                    (TERR_ID, TERR_RSC_ACCESS_ID, ORG_ID, ACTION, TRIGGER_MODE,
                    OLD_LAST_UPDATE_DATE, OLD_LAST_UPDATED_BY, OLD_CREATION_DATE, OLD_CREATED_BY, OLD_LAST_UPDATE_LOGIN,
                    NEW_LAST_UPDATE_DATE, NEW_LAST_UPDATED_BY, NEW_CREATION_DATE, NEW_CREATED_BY, NEW_LAST_UPDATE_LOGIN,
                    OLD_ACCESS_TYPE, NEW_ACCESS_TYPE)
                VALUES
                    (l_terr_id, l_terr_rsc_access_id, p_org_id, 'NEW_RECORD', 'ON-UPDATE',
                    o_LAST_UPDATE_DATE, o_LAST_UPDATED_BY, o_CREATION_DATE, o_CREATED_BY, o_LAST_UPDATE_LOGIN,
                    n_LAST_UPDATE_DATE, n_LAST_UPDATED_BY, n_CREATION_DATE, n_CREATED_BY, n_LAST_UPDATE_LOGIN,
                    o_access_type, n_access_type);
            EXCEPTION
                WHEN OTHERS THEN
                     --dbms_output.put_line('Failed at ON-UPDATE, NEW_RECORD'|| sqlerrm);
                     FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_RSC_ACCESS_BIUD-Handler', 'Error while inserting record for updating rsc access' || sqlerrm);
            END;
        End if;
    else
        -- Trigger_mode = 'ON-DELETE'
        If Changed_Terr_RscAcc_Rec_Exists = 'True' then
            BEGIN
                DELETE from JTF_CHANGED_TERR
                WHERE terr_id = l_terr_id
                    and TERR_RSC_ID is null
                    and terr_rsc_access_id = l_terr_rsc_access_id
                    and terr_qtype_usg_id is null
                    and terr_value_id is null
                    and request_id is null;
            EXCEPTION
                When OTHERS then
                    null;
                    FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERRITORIES_BIUD-Handler', 'Error deleting record for deleting terr rsc' || sqlerrm);
            End;
        else -- Changed_Terr_RscAccess_Rec_Exists = 'False'
            BEGIN
                INSERT INTO JTF_CHANGED_TERR
                    (TERR_ID, TERR_RSC_ACCESS_ID, ORG_ID, ACTION, TRIGGER_MODE,
                    OLD_LAST_UPDATE_DATE, OLD_LAST_UPDATED_BY, OLD_CREATION_DATE, OLD_CREATED_BY, OLD_LAST_UPDATE_LOGIN,
                    NEW_LAST_UPDATE_DATE, NEW_LAST_UPDATED_BY, NEW_CREATION_DATE, NEW_CREATED_BY, NEW_LAST_UPDATE_LOGIN,
                    OLD_ACCESS_TYPE, NEW_ACCESS_TYPE)
                VALUES
                    (l_terr_id, l_terr_rsc_access_id, p_org_id, 'NEW_RECORD', 'ON-DELETE',
                    o_LAST_UPDATE_DATE, o_LAST_UPDATED_BY, o_CREATION_DATE, o_CREATED_BY, o_LAST_UPDATE_LOGIN,
                    n_LAST_UPDATE_DATE, n_LAST_UPDATED_BY, n_CREATION_DATE, n_CREATED_BY, n_LAST_UPDATE_LOGIN,
                    o_access_type, n_access_type);
            EXCEPTION
                WHEN OTHERS THEN
                     --dbms_output.put_line('Failed at ON-DELETE, NEW_RECORD' || sqlerrm);
                     FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_RSC_ACCESS_BIUD-Handler', 'Error while inserting record for deleting rsc access ' || sqlerrm);
            END;
        End if;
    End if;
EXCEPTION
    When NOT_SALES_TERR_CHANGE then
         null;
    When OTHERS then
        FND_MSG_PUB.Add_Exc_Msg( 'JTF_TERR_RSC_ACCESS_BIUD-Handler', 'Problems: ' || sqlerrm);
        null;
END Terr_RscAccess_Trigger_Handler;


END JTF_TERR_TRIGGER_HANDLERS;

/
