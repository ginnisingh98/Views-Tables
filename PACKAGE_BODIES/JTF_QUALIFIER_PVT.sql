--------------------------------------------------------
--  DDL for Package Body JTF_QUALIFIER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_QUALIFIER_PVT" AS
/* $Header: jtfvtrqb.pls 120.0 2005/06/02 18:22:56 appldev ship $ */

--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_QUALIFIER_PVT
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager private api's.
--      This package is a private API for inserting, updating and deleting
--      qualifier related information into JTF tables.
--      It contains specification for pl/sql records and tables
--      and the Private territory related API's.
--
--      Procedures:
--
--
--    NOTES
--      This package is available for private use only.
--
--    HISTORY
--      07/15/99   JDOCHERT         Created
--      03/28/00   VNEDUNGA         Adding new columns for eliminating
--                                  dependency to AS_INTERESTS in
--                                  JTF_QUAL_USGS table
--
--    End of Comments
--


--    ***************************************************
--    GLOBAL VARIABLES
--    ***************************************************

G_PKG_NAME    CONSTANT VARCHAR2(30):='JTF_QUALIFIER_PVT';
G_FILE_NAME   CONSTANT VARCHAR2(12):='jtfvtrqb.pls';

G_APPL_ID        NUMBER         := FND_GLOBAL.Prog_Appl_Id;
G_LOGIN_ID       NUMBER         := FND_GLOBAL.Conc_Login_Id;
G_USER_ID        NUMBER         := FND_GLOBAL.User_Id;
G_APP_SHORT_NAME VARCHAR2(50)   := FND_GLOBAL.Application_Short_Name;


-- ******************************************************
-- PRIVATE ROUTINES
-- ******************************************************

/* Returns TRUE if mandatory information is missing from record,
** otherwise returns FALSE if information is complete
*/
FUNCTION is_seed_qual_rec_missing
         ( p_seed_qual_rec IN  JTF_QUALIFIER_PUB.Seed_Qual_Rec_Type)
RETURN VARCHAR2
IS
BEGIN

    IF (p_seed_qual_rec.name IS NULL OR
        p_seed_qual_rec.name = FND_API.G_MISS_CHAR OR
        p_seed_qual_rec.description IS NULL OR
        p_seed_qual_rec.description = FND_API.G_MISS_CHAR)
    THEN
        RETURN FND_API.G_TRUE;
    ELSE
        RETURN FND_API.G_FALSE;
    END IF;

END is_seed_qual_rec_missing;


/*  Validate the record information
**  All mandatory items are present
**  Convert missing values to defaults
*/
PROCEDURE validate_seed_qual_rec
         ( p_seed_qual_rec      IN  JTF_QUALIFIER_PUB.Seed_Qual_Rec_Type,
           p_validation_mode    IN VARCHAR2,
           p_validation_level   IN NUMBER,
           x_return_status      OUT NOCOPY VARCHAR2)
IS
    l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    l_seed_qual_rec JTF_QUALIFIER_PUB.Seed_Qual_Rec_Type := p_seed_qual_rec;

BEGIN



--    IF ( p_validation_level >=  JTF_CTM_UTILITY_PVT.G_VALID_LEVEL_ITEM ) THEN

    /* If record is being updated, check that primary key is not null */
    IF ( (p_validation_mode = JTF_CTM_UTILITY_PVT.G_UPDATE) AND
         (l_seed_qual_rec.seeded_qual_id IS NULL OR
          l_seed_qual_rec.seeded_qual_id = FND_API.G_MISS_NUM) )THEN


            l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

--    IF ( p_validation_level >=  JTF_CTM_UTILITY_PVT.G_VALID_LEVEL_RECORD ) THEN

    /* Check that all mandatory items exist in record */
    IF (is_seed_qual_rec_missing (p_seed_qual_rec) = FND_API.G_TRUE) THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        /* Debug message */
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            FND_MESSAGE.Set_Name ('JTF', 'PVTQUAL API:Miss req itms');
            FND_MESSAGE.Set_Token ('COLUMN', 'NAME, DESCRIPTION');
            FND_MSG_PUB.ADD;
        END IF;

    END IF;

    x_return_status := l_return_status;



END validate_seed_qual_rec;


/* Insert seeded qualifier record into database */
PROCEDURE Create_Seed_Qual_Record
            ( p_seed_qual_rec       IN  JTF_QUALIFIER_PUB.Seed_Qual_Rec_Type,
              x_seed_qual_out_rec   OUT NOCOPY JTF_QUALIFIER_PUB.Seed_Qual_Out_Rec_Type )
IS

    CURSOR c_chk_qual_name (l_qual_name VARCHAR2) IS
        SELECT seeded_qual_id
        FROM JTF_SEEDED_QUAL
        WHERE UPPER(name) = UPPER(l_qual_name);

    l_seeded_qual_id_csr    NUMBER;

    l_rowid                 ROWID;
    l_seed_qual_rec         JTF_QUALIFIER_PUB.Seed_Qual_Rec_Type := JTF_QUALIFIER_PUB.G_MISS_SEED_QUAL_REC;
    l_seed_qual_out_rec     JTF_QUALIFIER_PUB.Seed_Qual_Out_Rec_Type := JTF_QUALIFIER_PUB.G_MISS_SEED_QUAL_OUT_REC;

BEGIN

    -- Initialise API return status to success
    l_seed_qual_out_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    -- initialise local seeded qualifier record
    l_seed_qual_rec := p_seed_qual_rec;

    --    IF (l_seed_qual_rec.seeded_qual_id = FND_API.G_MISS_NUM) THEN
    --    END IF;
    -- check if qualifier with this name already exists
    OPEN c_chk_qual_name (l_seed_qual_rec.name);
    FETCH c_chk_qual_name INTO l_seeded_qual_id_csr;

    IF c_chk_qual_name%NOTFOUND THEN



        -- convert id to null, so that next value of sequence will
        -- be selected in default table handler
        IF (l_seed_qual_rec.seeded_qual_id = FND_API.G_MISS_NUM) THEN

            l_seed_qual_rec.seeded_qual_id := NULL;
        END IF;

        -- Call INSERT table handler
        JTF_SEEDED_QUAL_PKG.INSERT_ROW(
                                     X_Rowid                 => l_rowid,
                                     X_SEEDED_QUAL_ID        => l_seed_qual_rec.seeded_qual_id,
                                     X_LAST_UPDATE_DATE      => l_seed_qual_rec.LAST_UPDATE_DATE,
                                     X_LAST_UPDATED_BY       => l_seed_qual_rec.LAST_UPDATED_BY,
                                     X_CREATION_DATE         => l_seed_qual_rec.CREATION_DATE,
                                     X_CREATED_BY            => l_seed_qual_rec.CREATED_BY,
                                     X_LAST_UPDATE_LOGIN     => l_seed_qual_rec.LAST_UPDATE_LOGIN,
                                     X_NAME                  => l_seed_qual_rec.NAME,
                                     X_DESCRIPTION           => l_seed_qual_rec.DESCRIPTION,
                                     X_ORG_ID                => l_seed_qual_rec.ORG_ID
                                     );

        l_seed_qual_out_rec.seeded_qual_id := l_seed_qual_rec.seeded_qual_id;

    ELSE

        l_seed_qual_out_rec.seeded_qual_id := l_seeded_qual_id_csr;

        -- Debug message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            FND_MESSAGE.Set_Name ('JTF', 'PVTQUAL API:name exists');
            FND_MESSAGE.Set_Token ('ROW', 'JTF_SEEDED_QUAL_B');
            FND_MSG_PUB.ADD;
        END IF;

    END IF;

    CLOSE c_chk_qual_name;


    l_seed_qual_out_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    -- save id and status
    x_seed_qual_out_rec := l_seed_qual_out_rec;


END Create_Seed_Qual_Record;


-- Update seeded qualifier record in database
PROCEDURE Update_Seed_Qual_Record
            ( p_seed_qual_rec       IN  JTF_QUALIFIER_PUB.Seed_Qual_Rec_Type,
              x_seed_qual_out_rec   OUT NOCOPY JTF_QUALIFIER_PUB.Seed_Qual_Out_Rec_Type )
IS

    l_rowid                 ROWID;
    l_seed_qual_rec         JTF_QUALIFIER_PUB.Seed_Qual_Rec_Type := JTF_QUALIFIER_PUB.G_MISS_SEED_QUAL_REC;
    l_seed_qual_out_rec     JTF_QUALIFIER_PUB.Seed_Qual_Out_Rec_Type := JTF_QUALIFIER_PUB.G_MISS_SEED_QUAL_OUT_REC;

BEGIN
    -- Initialise API return status to success
    l_seed_qual_out_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    -- initialise local seeded qualifier record
    l_seed_qual_rec := p_seed_qual_rec;

    -- Call UPDATE table handler
    JTF_SEEDED_QUAL_PKG.UPDATE_ROW(
                                 X_Rowid                 => l_rowid,
                                 X_SEEDED_QUAL_ID        => l_seed_qual_rec.seeded_qual_id,
                                 X_LAST_UPDATE_DATE      => l_seed_qual_rec.LAST_UPDATE_DATE,
                                 X_LAST_UPDATED_BY       => l_seed_qual_rec.LAST_UPDATED_BY,
                                 X_CREATION_DATE         => l_seed_qual_rec.CREATION_DATE,
                                 X_CREATED_BY            => l_seed_qual_rec.CREATED_BY,
                                 X_LAST_UPDATE_LOGIN     => l_seed_qual_rec.LAST_UPDATE_LOGIN,
                                 X_NAME                  => l_seed_qual_rec.NAME,
                                 X_DESCRIPTION           => l_seed_qual_rec.DESCRIPTION,
                                 X_ORG_ID                => l_seed_qual_rec.ORG_ID
                                 );


    l_seed_qual_out_rec.seeded_qual_id := l_seed_qual_rec.seeded_qual_id;
    l_seed_qual_out_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    -- save id and status
    x_seed_qual_out_rec := l_seed_qual_out_rec;



END Update_Seed_Qual_Record;


-- Delete seeded qualifier record from database
PROCEDURE Delete_Seed_Qual_Record
            ( p_seeded_qual_id  IN  NUMBER,
              x_return_status   OUT NOCOPY VARCHAR2 )
IS

    l_rowid                 ROWID;
    l_return_status         VARCHAR2(1);

BEGIN

    -- Initialise API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call DELETE table handler
    JTF_SEEDED_QUAL_PKG.DELETE_ROW ( X_SEEDED_QUAL_ID => p_seeded_qual_id);

    -- save status
    x_return_status := l_return_status;


END Delete_Seed_Qual_Record;


-- *************************************************************************************
-- this function returns the datatype of a column
FUNCTION get_column_datatype(p_column_name VARCHAR2, p_table_name VARCHAR2)
RETURN VARCHAR2
IS
    -- cursor to check that column exists in an Application schema
    CURSOR c_column_datatype (l_column_name VARCHAR2, l_table_name VARCHAR2, l_apps_schema VARCHAR2) IS
    SELECT data_type
    FROM ALL_TAB_COLUMNS
    WHERE column_name = UPPER(l_column_name)
    AND table_name = UPPER(l_table_name)
    AND owner =
         (select table_owner
          from all_synonyms
          where synonym_name = UPPER(l_table_name)
          and   owner = l_apps_schema);

    -- column datatype
    l_column_datatype_csr ALL_TAB_COLUMNS.DATA_TYPE%TYPE;

    l_apps_schema_name   VARCHAR2(30);
BEGIN

     /* ACHANDA : Bug # 3511203 : get apps schema and use it to get the data type from all_tab_columns */
     SELECT oracle_username
     INTO   l_apps_schema_name
     FROM   fnd_oracle_userid
     WHERE  read_only_flag = 'U';

    -- get the column datatype
    OPEN c_column_datatype (p_column_name, p_table_name, l_apps_schema_name);
    FETCH c_column_datatype INTO l_column_datatype_csr;

    IF c_column_datatype%NOTFOUND THEN

        -- Debug message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            FND_MESSAGE.Set_Name ('JTF', 'PVTQUAL API:Col dtype noexist');
            FND_MESSAGE.Set_Token ( 'COLUMN', 'QUAL_TABLE1');
            FND_MSG_PUB.ADD;
        END IF;

        l_column_datatype_csr := NULL;

    END IF;

    CLOSE c_column_datatype;

    RETURN l_column_datatype_csr;

END get_column_datatype;

-- *************************************************************************************
-- Checks if there are territories using this qualifier
-- Determines if qualifier disable should be allowed
PROCEDURE check_qualifier_usage
        (l_qual_usg_id IN NUMBER,
         l_qualifier_used OUT NOCOPY VARCHAR2 )
IS
    l_count NUMBER;

BEGIN

    select 1
    into    l_count
    from    jtf_terr                jta,
            jtf_terr_qual           jtq
    where jta.terr_id = jtq.terr_id
          and jtq.qual_usg_id = l_qual_usg_id
          and rownum < 2;

    If l_count > 0 then
        l_qualifier_used := 'TRUE';
    end if;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        l_qualifier_used := 'FALSE';
    WHEN OTHERS THEN
        l_qualifier_used := 'NEITHER';

END check_qualifier_usage;

----------------------------------------------------------------------

-- Converts missing items' values to default values
PROCEDURE convert_miss_qual_usgs_rec
          ( p_qual_usgs_rec IN  JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type,
            x_qual_usgs_rec OUT NOCOPY JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type)
IS

    l_qual_usgs_rec JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type := p_qual_usgs_rec;

BEGIN

    IF (l_qual_usgs_rec.enabled_flag = FND_API.G_MISS_CHAR) THEN
        l_qual_usgs_rec.enabled_flag := 'N';
    END IF;




    IF (l_qual_usgs_rec.qual_col1_datatype = FND_API.G_MISS_CHAR) THEN
       l_qual_usgs_rec.qual_col1_datatype := get_column_datatype( l_qual_usgs_rec.qual_col1,
                                                                  l_qual_usgs_rec.qual_col1_table);
    END IF;

    IF (l_qual_usgs_rec.prim_int_cde_col_datatype = FND_API.G_MISS_CHAR) THEN

        IF (l_qual_usgs_rec.prim_int_cde_col <> FND_API.G_MISS_CHAR
            AND l_qual_usgs_rec.int_cde_col_table <> FND_API.G_MISS_CHAR) THEN

            l_qual_usgs_rec.prim_int_cde_col_datatype := get_column_datatype( l_qual_usgs_rec.prim_int_cde_col,
                                                                              l_qual_usgs_rec.int_cde_col_table);
        END IF;

    END IF;

    IF (l_qual_usgs_rec.sec_int_cde_col_datatype = FND_API.G_MISS_CHAR) THEN

        IF (l_qual_usgs_rec.sec_int_cde_col <> FND_API.G_MISS_CHAR
            AND l_qual_usgs_rec.int_cde_col_table <> FND_API.G_MISS_CHAR) THEN

            l_qual_usgs_rec.sec_int_cde_col_datatype := get_column_datatype( l_qual_usgs_rec.sec_int_cde_col,
                                                                       l_qual_usgs_rec.int_cde_col_table);
        END IF;

    END IF;




    x_qual_usgs_rec := l_qual_usgs_rec;

END convert_miss_qual_usgs_rec;


-- Returns TRUE if mandatory information is missing from record,
-- otherwise returns FALSE if information is complete
FUNCTION is_qual_usgs_rec_missing
         ( p_qual_usgs_rec IN  JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type)
RETURN VARCHAR2
IS
BEGIN

    IF ( p_qual_usgs_rec.qual_type_usg_id IS NULL OR
         p_qual_usgs_rec.qual_type_usg_id = FND_API.G_MISS_NUM OR
         p_qual_usgs_rec.qual_col1 IS NULL OR
         p_qual_usgs_rec.qual_col1 = FND_API.G_MISS_CHAR OR
         p_qual_usgs_rec.qual_col1_alias IS NULL OR
         p_qual_usgs_rec.qual_col1_alias = FND_API.G_MISS_CHAR OR
         p_qual_usgs_rec.qual_col1_datatype IS NULL OR
         p_qual_usgs_rec.qual_col1_datatype = FND_API.G_MISS_CHAR OR
         p_qual_usgs_rec.qual_col1_table IS NULL OR
         p_qual_usgs_rec.qual_col1_table = FND_API.G_MISS_CHAR OR
         p_qual_usgs_rec.qual_col1_table_alias IS NULL OR
         p_qual_usgs_rec.qual_col1_table_alias = FND_API.G_MISS_CHAR
        )
    THEN
         -- Debug message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            FND_MESSAGE.Set_Name ('JTF', 'PVTQUAL API:Miss mandtry itms');
            FND_MESSAGE.Set_Token ( 'COLUMN',
                                    'QUAL_TYPE_USG_ID, ' ||
                                    'QUAL_COL1, QUAL_COL1_ALIAS, QUAL_COL1_DATATYPE, ' ||
                                    'QUAL_COL1_TABLE, QUAL_COL1_TABLE_ALIAS');
            FND_MSG_PUB.ADD;
        END IF;

        RETURN FND_API.G_TRUE;
    ELSE
        RETURN FND_API.G_FALSE;
    END IF;

END is_qual_usgs_rec_missing;


/* function returns TRUE if table and column that define the Qualifier
** are valid, otherwise returns FALSE
*/
FUNCTION table_col_is_valid (p_table_name VARCHAR2, p_col_name VARCHAR2)
RETURN VARCHAR2
IS

    -- cursor to check that table exists in an Application schema
    CURSOR c_chk_table_exists (l_table_name VARCHAR2, l_apps_schema VARCHAR2) IS
    SELECT 'X'
    FROM ALL_TAB_COLUMNS
    WHERE table_name = UPPER(l_table_name)
    AND owner =
         (select table_owner
          from all_synonyms
          where synonym_name = UPPER(l_table_name)
          and   owner = l_apps_schema);

    -- cursor to check that column exists in an Application schema
    CURSOR c_chk_col_exists (l_table_name VARCHAR2, l_col_name VARCHAR2, l_apps_schema VARCHAR2) IS
    SELECT 'X'
    FROM ALL_TAB_COLUMNS
    WHERE column_name = UPPER(l_col_name)
    AND table_name = UPPER(l_table_name)
    AND owner =
         (select table_owner
          from all_synonyms
          where synonym_name = UPPER(l_table_name)
          and   owner = l_apps_schema);

    l_return_csr        VARCHAR2(1);
    l_return_variable   VARCHAR2(1) := FND_API.G_TRUE;
    l_apps_schema_name   VARCHAR2(30);

BEGIN

     /* ACHANDA : Bug # 3511203 : get apps schema and use it to get the data type from all_tab_columns */
     SELECT oracle_username
     INTO   l_apps_schema_name
     FROM   fnd_oracle_userid
     WHERE  read_only_flag = 'U';

    /* check if table exists */
    OPEN c_chk_table_exists (p_table_name, l_apps_schema_name);
    FETCH c_chk_table_exists INTO l_return_csr;

    IF c_chk_table_exists%NOTFOUND THEN

       l_return_variable := FND_API.G_FALSE;

       /* Debug message */
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
              FND_MESSAGE.Set_Name ('JTF', 'PVTQUAL API:Table dnot exist');
              FND_MESSAGE.Set_Token ('TABLE', p_table_name);
              FND_MSG_PUB.ADD;
        END IF;

    END IF;

    CLOSE c_chk_table_exists;





    /* check if column exists */
    OPEN c_chk_col_exists (p_table_name, p_col_name, l_apps_schema_name);
    FETCH c_chk_col_exists INTO l_return_csr;

    IF c_chk_col_exists%NOTFOUND THEN

       l_return_variable := FND_API.G_FALSE;

       /* Debug message */
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
          FND_MESSAGE.Set_Name ('JTF',  'PVTQUAL API:Column dnot exist');
          FND_MESSAGE.Set_Token ('COLUMN', p_col_name);
          FND_MSG_PUB.ADD;
       END IF;

    END IF;

    CLOSE c_chk_col_exists;

    RETURN l_return_variable;

END table_col_is_valid;


/* Returns TRUE if the optional information for the record is valid,
** returns otherwise FALSE
** As none of these items are required, they are set to their default
** value, so that the record can still be inserted into the database
** Checks items that use lookup values
*/
FUNCTION qual_usgs_info_is_valid
         ( p_qual_usgs_rec IN OUT NOCOPY JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type)
RETURN VARCHAR2
IS

    /* return varaible */
    l_return_variable   VARCHAR2(1) := FND_API.G_TRUE;

    /* local scratch record */
    l_qual_usgs_rec JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type;

BEGIN


    /* initialise local record */
    l_qual_usgs_rec := p_qual_usgs_rec;

    IF ( JTF_CTM_UTILITY_PVT.lookup_code_is_valid ( l_qual_usgs_rec.seeded_flag
                                                    , 'FLAG'
                                                    , 'FND_LOOKUPS') = FND_API.G_FALSE) THEN
        l_return_variable := FND_API.G_FALSE;
        l_qual_usgs_rec.seeded_flag := 'N';
    END IF;

    IF ( JTF_CTM_UTILITY_PVT.lookup_code_is_valid ( l_qual_usgs_rec.display_type
                                                    , 'DISPLAY_TYPE'
                                                    , 'FND_LOOKUPS') = FND_API.G_FALSE) THEN
        l_return_variable := FND_API.G_FALSE;
        l_qual_usgs_rec.display_type := 'STANDARD';
    END IF;

    RETURN l_return_variable;

END qual_usgs_info_is_valid;


/*  Validate the record information
**  All mandatory items are present
**  Convert missing values to defaults
*/
PROCEDURE validate_qual_usgs_rec
         ( p_qual_usgs_rec      IN  JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type,
           p_validation_mode    IN  VARCHAR2,
           p_validation_level   IN  NUMBER,
           x_return_status      OUT NOCOPY VARCHAR2)
IS

    -- cursor to check that Unique Key constraint not violated
    CURSOR c_chk_uk_violation (p_seeded_qual_id NUMBER, p_qual_type_usg_id NUMBER) IS
    SELECT 'X'
    FROM JTF_QUAL_USGS
    WHERE seeded_qual_id = p_seeded_qual_id
      AND qual_type_usg_id = p_qual_type_usg_id;

    l_return_csr        VARCHAR2(1);

    -- Initialise return status
    l_return_status VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    -- Initialise local Qualifer Usages record
    l_qual_usgs_rec JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type := p_qual_usgs_rec;

BEGIN


--    IF ( p_validation_level >=  JTF_CTM_UTILITY_PVT.G_VALID_LEVEL_ITEM ) THEN

    /* If record is being updated, check that primary key is not null */
    IF ( (p_validation_mode = JTF_CTM_UTILITY_PVT.G_UPDATE) AND
         ( l_qual_usgs_rec.qual_usg_id IS NULL OR
           l_qual_usgs_rec.qual_usg_id = FND_API.G_MISS_NUM) ) THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

    END IF;


--    IF ( p_validation_level >=  JTF_CTM_UTILITY_PVT.G_VALID_LEVEL_RECORD ) THEN

    /* Check that all mandatory items exist in record */
    IF (is_qual_usgs_rec_missing (l_qual_usgs_rec) = FND_API.G_TRUE) THEN
        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;




--    IF ( p_validation_level >=  JTF_CTM_UTILITY_PVT.G_VALID_LEVEL_INTER_ENTITY ) THEN

    /* check FK reference to JTF_SEEDED_QUAL */
    IF ( l_qual_usgs_rec.seeded_qual_id IS NOT NULL AND
         l_qual_usgs_rec.seeded_qual_id <> FND_API.G_MISS_NUM ) THEN

        IF ( JTF_CTM_UTILITY_PVT.fk_id_is_valid (
                              l_qual_usgs_rec.seeded_qual_id,
                              'SEEDED_QUAL_ID',
                              'JTF_SEEDED_QUAL') = FND_API.G_FALSE)
        THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;




--    IF ( p_validation_level >=  JTF_CTM_UTILITY_PVT.G_VALID_LEVEL_INTER_ENTITY ) THEN

    /* check FK reference to JTF_QUAL_TYPE_USGS */
    IF ( l_qual_usgs_rec.qual_type_usg_id IS NOT NULL AND
         l_qual_usgs_rec.qual_type_usg_id <> FND_API.G_MISS_NUM ) THEN

        IF ( JTF_CTM_UTILITY_PVT.fk_id_is_valid (
                              l_qual_usgs_rec.qual_type_usg_id,
                              'QUAL_TYPE_USG_ID',
                              'JTF_QUAL_TYPE_USGS') = FND_API.G_FALSE)
        THEN
            l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
    END IF;



    /* If record is being updated, check that primary key is not null */
    IF (p_validation_mode = JTF_CTM_UTILITY_PVT.G_CREATE) THEN

        /* check that Unique Key constraint not violated */
        IF ( l_qual_usgs_rec.seeded_qual_id IS NOT NULL AND
             l_qual_usgs_rec.seeded_qual_id <> FND_API.G_MISS_NUM  AND
             l_qual_usgs_rec.qual_type_usg_id IS NOT NULL AND
             l_qual_usgs_rec.qual_type_usg_id <> FND_API.G_MISS_NUM )THEN

            /* check if rec already exists */
            OPEN c_chk_uk_violation ( l_qual_usgs_rec.seeded_qual_id
                                    , l_qual_usgs_rec.qual_type_usg_id);
            FETCH c_chk_uk_violation INTO l_return_csr;

            IF c_chk_uk_violation%FOUND THEN

               l_return_status := FND_API.G_RET_STS_ERROR;

               /* Debug message */
               IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                  FND_MESSAGE.Set_Name ('JTF', 'PVTQUAL API:UK Violation');
                  FND_MESSAGE.Set_Token ('TABLE', 'JTF_QUAL_USGS');
                  FND_MSG_PUB.ADD;
                END IF;

            END IF; /* c_chk_uk_violation%FOUND */

        CLOSE c_chk_uk_violation;

        END IF;
    END IF;




--    IF ( p_validation_level >=  JTF_CTM_UTILITY_PVT.G_VALID_LEVEL_RECORD ) THEN

    /* check qualifier column and table exists */
    IF ( l_qual_usgs_rec.qual_col1_table IS NOT NULL AND
         l_qual_usgs_rec.qual_col1_table <> FND_API.G_MISS_CHAR AND
         l_qual_usgs_rec.qual_col1 IS NOT NULL AND
         l_qual_usgs_rec.qual_col1 <> FND_API.G_MISS_CHAR ) THEN

        /* if qualifier has been defined as a special function, do
        ** not check if table and column definitions exist
        */
        IF (l_qual_usgs_rec.qual_col1_datatype <> 'SPECIAL_FUNCTION') THEN

            IF (table_col_is_valid ( l_qual_usgs_rec.qual_col1_table,
                                     l_qual_usgs_rec.qual_col1) = FND_API.G_FALSE)
            THEN
                l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

        END IF;
    END IF;




--    IF ( p_validation_level >=  JTF_CTM_UTILITY_PVT.G_VALID_LEVEL_RECORD ) THEN

    /* check qualifier column and table exists */
    IF ( l_qual_usgs_rec.int_cde_col_table IS NOT NULL AND
         l_qual_usgs_rec.int_cde_col_table <> FND_API.G_MISS_CHAR AND
         l_qual_usgs_rec.prim_int_cde_col IS NOT NULL AND
         l_qual_usgs_rec.prim_int_cde_col <> FND_API.G_MISS_CHAR ) THEN

        IF (table_col_is_valid ( l_qual_usgs_rec.int_cde_col_table,
                                 l_qual_usgs_rec.prim_int_cde_col) = FND_API.G_FALSE)
        THEN

            l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;




    --    IF ( p_validation_level >=  JTF_CTM_UTILITY_PVT.G_VALID_LEVEL_RECORD ) THEN

    /* check qualifier column and table exists */
    IF ( l_qual_usgs_rec.int_cde_col_table IS NOT NULL AND
         l_qual_usgs_rec.int_cde_col_table <> FND_API.G_MISS_CHAR AND
         l_qual_usgs_rec.sec_int_cde_col IS NOT NULL AND
         l_qual_usgs_rec.sec_int_cde_col <> FND_API.G_MISS_CHAR ) THEN

        IF (table_col_is_valid ( l_qual_usgs_rec.int_cde_col_table,
                                 l_qual_usgs_rec.sec_int_cde_col) = FND_API.G_FALSE)
        THEN

            l_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

    END IF;




    /* save return status */
    x_return_status := l_return_status;

END validate_qual_usgs_rec;




-- Insert qualifier usage record into database
PROCEDURE Create_Qual_Usgs_Record
            ( p_seed_qual_id        IN  NUMBER,
              p_qual_usgs_rec       IN  JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type,
              x_qual_usgs_out_rec   OUT NOCOPY JTF_QUALIFIER_PUB.Qual_Usgs_All_Out_Rec_Type)
IS

    l_return_csr            VARCHAR2(1);

    l_rowid                 ROWID;
    l_qual_usgs_rec     JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type := JTF_QUALIFIER_PUB.G_MISS_QUAL_USGS_ALL_REC;
    l_qual_usgs_out_rec JTF_QUALIFIER_PUB.Qual_Usgs_All_Out_Rec_Type := JTF_QUALIFIER_PUB.G_MISS_QUAL_USGS_ALL_OUT_REC;

BEGIN

    l_qual_usgs_rec := p_qual_usgs_rec;

    -- Initialise API return status to success
    l_qual_usgs_out_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    -- convert id to null, so that next value of sequence will
    -- be selected
    IF (l_qual_usgs_rec.qual_usg_id = FND_API.G_MISS_NUM) THEN


        l_qual_usgs_rec.qual_usg_id := NULL;
    END IF;
    -- Call INSERT table handler
    JTF_QUAL_USGS_PKG.INSERT_ROW(
        X_Rowid                        => l_rowid,
        X_QUAL_USG_ID                  => l_qual_usgs_rec.QUAL_USG_ID,
        X_LAST_UPDATE_DATE             => l_qual_usgs_rec.LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY              => l_qual_usgs_rec.LAST_UPDATED_BY,
        X_CREATION_DATE                => l_qual_usgs_rec.CREATION_DATE,
        X_CREATED_BY                   => l_qual_usgs_rec.CREATED_BY,
        X_LAST_UPDATE_LOGIN            => l_qual_usgs_rec.LAST_UPDATE_LOGIN,
        X_APPLICATION_SHORT_NAME       => l_qual_usgs_rec.APPLICATION_SHORT_NAME,
        X_SEEDED_QUAL_ID               => p_seed_qual_id,
        X_QUAL_TYPE_USG_ID             => l_qual_usgs_rec.QUAL_TYPE_USG_ID,
        X_ENABLED_FLAG                 => l_qual_usgs_rec.ENABLED_FLAG,
        X_QUAL_COL1                    => l_qual_usgs_rec.QUAL_COL1,
        X_QUAL_COL1_ALIAS              => l_qual_usgs_rec.QUAL_COL1_ALIAS,
        X_QUAL_COL1_DATATYPE           => l_qual_usgs_rec.QUAL_COL1_DATATYPE,
        X_QUAL_COL1_TABLE              => l_qual_usgs_rec.QUAL_COL1_TABLE,
        X_QUAL_COL1_TABLE_ALIAS        => l_qual_usgs_rec.QUAL_COL1_TABLE_ALIAS,
        X_PRIM_INT_CDE_COL             => l_qual_usgs_rec.PRIM_INT_CDE_COL,
        X_PRIM_INT_CDE_COL_DATATYPE    => l_qual_usgs_rec.PRIM_INT_CDE_COL_DATATYPE,
        X_PRIM_INT_CDE_COL_ALIAS       => l_qual_usgs_rec.PRIM_INT_CDE_COL_ALIAS,
        X_SEC_INT_CDE_COL              => l_qual_usgs_rec.SEC_INT_CDE_COL,
        X_SEC_INT_CDE_COL_ALIAS        => l_qual_usgs_rec.SEC_INT_CDE_COL_ALIAS,
        X_SEC_INT_CDE_COL_DATATYPE     => l_qual_usgs_rec.SEC_INT_CDE_COL_DATATYPE,
        X_INT_CDE_COL_TABLE            => l_qual_usgs_rec.INT_CDE_COL_TABLE,
        X_INT_CDE_COL_TABLE_ALIAS      => l_qual_usgs_rec.INT_CDE_COL_TABLE_ALIAS,
        X_SEEDED_FLAG                  => l_qual_usgs_rec.SEEDED_FLAG,
        X_DISPLAY_TYPE                 => l_qual_usgs_rec.DISPLAY_TYPE,
        X_LOV_SQL                      => l_qual_usgs_rec.LOV_SQL,
        x_CONVERT_TO_ID_FLAG           => l_qual_usgs_rec.CONVERT_TO_ID_FLAG,
        x_COLUMN_COUNT                 => l_qual_usgs_rec.COLUMN_COUNT,
        x_FORMATTING_FUNCTION_FLAG     => l_qual_usgs_rec.FORMATTING_FUNCTION_FLAG,
        x_FORMATTING_FUNCTION_NAME     => l_qual_usgs_rec.FORMATTING_FUNCTION_NAME,
        x_SPECIAL_FUNCTION_FLAG        => l_qual_usgs_rec.SPECIAL_FUNCTION_FLAG,
        x_SPECIAL_FUNCTION_NAME        => l_qual_usgs_rec.SPECIAL_FUNCTION_NAME,
        x_ENABLE_LOV_VALIDATION        => l_qual_usgs_rec.ENABLE_LOV_VALIDATION,
        x_DISPLAY_SQL1                 => l_qual_usgs_rec.DISPLAY_SQL1,
        x_LOV_SQL2                     => l_qual_usgs_rec.LOV_SQL2,
        x_DISPLAY_SQL2                 => l_qual_usgs_rec.DISPLAY_SQL2,
        x_LOV_SQL3                     => l_qual_usgs_rec.LOV_SQL3,
        x_DISPLAY_SQL3                 => l_qual_usgs_rec.DISPLAY_SQL3,
        X_ORG_ID                       => l_qual_usgs_rec.ORG_ID,
        X_RULE1                        => l_qual_usgs_rec.RULE1,
        X_RULE2                        => l_qual_usgs_rec.RULE2,
        X_DISPLAY_SEQUENCE             => l_qual_usgs_rec.DISPLAY_SEQUENCE,
        X_DISPLAY_LENGTH               => l_qual_usgs_rec.DISPLAY_LENGTH,
        X_JSP_LOV_SQL                  => l_qual_usgs_rec.JSP_LOV_SQL,
        x_use_in_lookup_flag           => l_qual_usgs_rec.use_in_lookup_flag);



    l_qual_usgs_out_rec.qual_usg_id := l_qual_usgs_rec.qual_usg_id;



    l_qual_usgs_out_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    -- save id and status
    x_qual_usgs_out_rec := l_qual_usgs_out_rec;

--exception
--when others then



END Create_Qual_Usgs_Record;


-- Update qualifier usage record in database
PROCEDURE Update_Qual_Usgs_Record
            ( p_qual_usgs_rec       IN  JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type,
              x_qual_usgs_out_rec   OUT NOCOPY JTF_QUALIFIER_PUB.Qual_Usgs_All_Out_Rec_Type)
IS

    l_rowid                 ROWID;
    l_qual_usgs_rec     JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type := JTF_QUALIFIER_PUB.G_MISS_QUAL_USGS_ALL_REC;
    l_qual_usgs_out_rec JTF_QUALIFIER_PUB.Qual_Usgs_All_Out_Rec_Type := JTF_QUALIFIER_PUB.G_MISS_QUAL_USGS_ALL_OUT_REC;

BEGIN


    -- initialize locak seeded qualifier record
    l_qual_usgs_rec := p_qual_usgs_rec;

    -- Initialise API return status to success
    l_qual_usgs_out_rec.return_status := FND_API.G_RET_STS_SUCCESS;


-- by eihsu, using similar method of problem resolution as in procedure Update_Seed_Qual_Record
-- (vinoo and jdochert)

   -- Call UPDATE table handler

 JTF_QUAL_USGS_PKG.UPDATE_ROW(
X_Rowid             => l_rowid,
X_QUAL_USG_ID           => l_qual_usgs_rec.QUAL_USG_ID,
X_LAST_UPDATE_DATE      => l_qual_usgs_rec.LAST_UPDATE_DATE,
X_LAST_UPDATED_BY       => l_qual_usgs_rec.LAST_UPDATED_BY,
X_CREATION_DATE         => l_qual_usgs_rec.CREATION_DATE,
X_CREATED_BY            => l_qual_usgs_rec.CREATED_BY,
X_LAST_UPDATE_LOGIN     => l_qual_usgs_rec.LAST_UPDATE_LOGIN,
X_APPLICATION_SHORT_NAME    => l_qual_usgs_rec.APPLICATION_SHORT_NAME,
X_SEEDED_QUAL_ID        => l_qual_usgs_rec.SEEDED_QUAL_ID,
X_QUAL_TYPE_USG_ID      => l_qual_usgs_rec.QUAL_TYPE_USG_ID,
X_ENABLED_FLAG          => l_qual_usgs_rec.ENABLED_FLAG,
X_QUAL_COL1         => l_qual_usgs_rec.QUAL_COL1,
X_QUAL_COL1_ALIAS       => l_qual_usgs_rec.QUAL_COL1_ALIAS,
X_QUAL_COL1_DATATYPE        => l_qual_usgs_rec.QUAL_COL1_DATATYPE,
X_QUAL_COL1_TABLE       => l_qual_usgs_rec.QUAL_COL1_TABLE,
X_QUAL_COL1_TABLE_ALIAS     => l_qual_usgs_rec.QUAL_COL1_TABLE_ALIAS,
X_PRIM_INT_CDE_COL      => l_qual_usgs_rec.PRIM_INT_CDE_COL,
X_PRIM_INT_CDE_COL_DATATYPE => l_qual_usgs_rec.PRIM_INT_CDE_COL_DATATYPE,
X_PRIM_INT_CDE_COL_ALIAS    => l_qual_usgs_rec.PRIM_INT_CDE_COL_ALIAS,
X_SEC_INT_CDE_COL       => l_qual_usgs_rec.SEC_INT_CDE_COL,
X_SEC_INT_CDE_COL_ALIAS     => l_qual_usgs_rec.SEC_INT_CDE_COL_ALIAS,
X_SEC_INT_CDE_COL_DATATYPE  => l_qual_usgs_rec.SEC_INT_CDE_COL_DATATYPE,
X_INT_CDE_COL_TABLE     => l_qual_usgs_rec.INT_CDE_COL_TABLE,
X_INT_CDE_COL_TABLE_ALIAS   => l_qual_usgs_rec.INT_CDE_COL_TABLE_ALIAS,
X_SEEDED_FLAG           => l_qual_usgs_rec.SEEDED_FLAG,
X_DISPLAY_TYPE          => l_qual_usgs_rec.DISPLAY_TYPE,
X_LOV_SQL               => l_qual_usgs_rec.LOV_SQL,
x_CONVERT_TO_ID_FLAG    => l_qual_usgs_rec.CONVERT_TO_ID_FLAG,
x_COLUMN_COUNT          => l_qual_usgs_rec.COLUMN_COUNT,
x_FORMATTING_FUNCTION_FLAG => l_qual_usgs_rec.FORMATTING_FUNCTION_FLAG,
x_FORMATTING_FUNCTION_NAME => l_qual_usgs_rec.FORMATTING_FUNCTION_NAME,
x_SPECIAL_FUNCTION_FLAG  => l_qual_usgs_rec.SPECIAL_FUNCTION_FLAG,
x_SPECIAL_FUNCTION_NAME  => l_qual_usgs_rec.SPECIAL_FUNCTION_NAME,
x_ENABLE_LOV_VALIDATION => l_qual_usgs_rec.ENABLE_LOV_VALIDATION,
x_DISPLAY_SQL1 => l_qual_usgs_rec.DISPLAY_SQL1,
x_LOV_SQL2 => l_qual_usgs_rec.LOV_SQL2,
x_DISPLAY_SQL2  => l_qual_usgs_rec.DISPLAY_SQL2,
x_LOV_SQL3 => l_qual_usgs_rec.LOV_SQL3,
x_DISPLAY_SQL3 => l_qual_usgs_rec.DISPLAY_SQL3,
X_ORG_ID => l_qual_usgs_rec.ORG_ID,
X_RULE1                 => l_qual_usgs_rec.RULE1,
X_RULE2                 => l_qual_usgs_rec.RULE2,
X_DISPLAY_SEQUENCE      => l_qual_usgs_rec.DISPLAY_SEQUENCE,
X_DISPLAY_LENGTH        => l_qual_usgs_rec.DISPLAY_LENGTH,
X_JSP_LOV_SQL           => l_qual_usgs_rec.JSP_LOV_SQL,
X_use_in_lookup_flag           => l_qual_usgs_rec.use_in_lookup_flag
	 );

    l_qual_usgs_out_rec.qual_usg_id := l_qual_usgs_rec.qual_usg_id;
    l_qual_usgs_out_rec.return_status := FND_API.G_RET_STS_SUCCESS;

    -- save id and status
    x_qual_usgs_out_rec := l_qual_usgs_out_rec;



END Update_Qual_Usgs_Record;


/* Check if records should be deleted
** seeded flag <> Y
** cannot delete seeded_qual if more that one qual_usg exists for that qualifier
** cannot delete qualifier if it is being used in a territory or territory type definition
** check if record should be deleted
*/
PROCEDURE is_qualifier_delete_allowed ( p_seeded_qual_id   IN  NUMBER
                                      , p_qual_usg_id      IN  NUMBER
                                      , x_return_status    OUT NOCOPY VARCHAR2 )
IS

    /* seeded qualifier record does not have more than one child */
    CURSOR c_chk_sq_child ( p_seeded_qual_id NUMBER, p_qual_usg_id NUMBER ) IS
    SELECT qual_usg_id
    FROM JTF_QUAL_USGS
    WHERE seeded_qual_id = p_seeded_qual_id
    AND qual_usg_id <> p_qual_usg_id;

    /* cursor to check if qualifier usage record is seeded */
    CURSOR  c_chk_seeded_flag ( p_qual_usg_id NUMBER ) IS
    SELECT qual_usg_id
    FROM JTF_QUAL_USGS
    WHERE seeded_flag = 'Y'
    AND qual_usg_id = p_qual_usg_id;

    /* cursor to check if qualifier usage is used in a territory definition */
    CURSOR c_chk_terr ( p_qual_usg_id NUMBER ) IS
    SELECT terr_qual_id
    FROM JTF_TERR_QUAL
    WHERE qual_usg_id = p_qual_usg_id;

    /* cursor to check if qualifier usage is used in a territory type definition */
    CURSOR c_chk_terr_type ( p_qual_usg_id NUMBER ) IS
    SELECT terr_type_qual_id
    FROM JTF_TERR_TYPE_QUAL
    WHERE qual_usg_id = p_qual_usg_id;

    /* cursor return variable */
    dummy_csr       NUMBER;

    /* local return variable */
    l_return_status     VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;

    /* local scratch variables */
    l_seeded_qual_id    NUMBER  := p_seeded_qual_id;
    l_qual_usg_id       NUMBER  := p_qual_usg_id;

BEGIN

    /* check for existence of other child records */
    OPEN c_chk_sq_child ( l_seeded_qual_id, l_qual_usg_id );
    FETCH c_chk_sq_child INTO dummy_csr;
    IF c_chk_sq_child%FOUND THEN

        /* Debug Message */
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
        THEN
            FND_MESSAGE.Set_Name('JTF', 'DELETE QUAL PVT: CHECK_DEL1');
            FND_MSG_PUB.Add;
        END IF;

        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;




    /* check if qualifier is seeded */
    OPEN c_chk_seeded_flag ( l_qual_usg_id );
    FETCH c_chk_seeded_flag INTO dummy_csr;
    IF c_chk_seeded_flag%FOUND THEN

        /* Debug Message */
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
        THEN
            FND_MESSAGE.Set_Name('JTF', 'DELETE QUAL PVT: CHECK_DEL2');
            FND_MSG_PUB.Add;
        END IF;

        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    OPEN c_chk_terr ( l_qual_usg_id );


    FETCH c_chk_terr INTO dummy_csr;


    IF c_chk_terr%FOUND THEN
        /* Debug Message */
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
        THEN
            FND_MESSAGE.Set_Name('JTF', 'DELETE QUAL PVT: CHECK_DEL3');
            FND_MSG_PUB.Add;
        END IF;

        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;





    /* check if qualifier is being used by a territory type */
    OPEN c_chk_terr_type ( l_qual_usg_id );
    FETCH c_chk_terr_type INTO dummy_csr;
    IF c_chk_terr_type%FOUND THEN

        /* Debug Message */
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
        THEN
            FND_MESSAGE.Set_Name('JTF', 'DELETE QUAL PVT: CHECK_DEL4');
            FND_MSG_PUB.Add;
        END IF;

        l_return_status := FND_API.G_RET_STS_ERROR;
    END IF;



    /* save status */
    x_return_status := l_return_status;

END;



-- Delete qualifier usage record from database
PROCEDURE Delete_Qual_Usgs_Record
            ( p_qual_usg_id     IN  NUMBER,
              x_return_status   OUT NOCOPY VARCHAR2 )
IS

    l_rowid                 ROWID;
    l_return_status         VARCHAR2(1);

BEGIN


    -- Initialise API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call UPDATE table handler
    JTF_QUAL_USGS_PKG.DELETE_ROW ( X_QUAL_USG_ID => p_qual_usg_id);

    -- save status
    x_return_status := l_return_status;

END Delete_Qual_Usgs_Record;


-- ******************************************************
-- PUBLIC ROUTINES
-- ******************************************************

--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Create_Qualifier
--    Type      : PRIVATE
--    Function  : To create qualifiers
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name         Data Type                                Default
--      p_api_version          NUMBER
--      p_Seed_Qual_Rec        JTF_QUALIFIER_PUB.Seed_Qual_Rec_Type     JTF_QUALIFIER_PUB.G_MISS_SEED_QUAL_REC
--      p_Qual_Usgs_Rec        JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type JTF_QUALIFIER_PUB.G_MISS_QUAL_USGS_ALL_REC
--
--      Optional
--      Parameter Name         Data Type                                Default
--      P_Init_Msg_List        VARCHAR2                                 FND_API.G_FALSE
--      P_Commit               VARCHAR2                                 FND_API.G_FALSE
--      p_validation_level     VARCHAR2                                 FND_API.G_VALID_LEVEL_FULL
--
--     OUT     :
--      Parameter Name         Data Type                                Default
--      x_Return_Status        VARCHAR2(1)
--      x_Msg_Count            NUMBER
--      x_Msg_Data             VARCHAR2(2000)
--      x_Seeded_Qual_Id       NUMBER
--      x_Qual_Usgs_Id         NUMBER
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Create_Qualifier
(p_api_version         IN    NUMBER,
 p_Init_Msg_List       IN    VARCHAR2 := FND_API.G_FALSE,
 p_Commit              IN    VARCHAR2 := FND_API.G_FALSE,
 p_validation_level    IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
 x_Return_Status       OUT NOCOPY   VARCHAR2,
 x_Msg_Count           OUT NOCOPY   NUMBER,
 x_Msg_Data            OUT NOCOPY   VARCHAR2,
 --                                             commented eihsu 11/04
 p_Seed_Qual_Rec       IN    JTF_QUALIFIER_PUB.Seed_Qual_Rec_Type     ,--:= JTF_QUALIFIER_PUB.G_MISS_SEED_QUAL_REC,
 p_Qual_Usgs_Rec       IN    JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type ,--:= JTF_QUALIFIER_PUB.G_MISS_QUAL_USGS_ALL_REC,
 x_Seed_Qual_Rec       OUT NOCOPY   JTF_QUALIFIER_PUB.Seed_Qual_Out_Rec_Type,
 x_Qual_Usgs_Rec       OUT NOCOPY   JTF_QUALIFIER_PUB.Qual_Usgs_All_Out_Rec_Type
)
IS
    l_api_name              CONSTANT VARCHAR2(30) := 'Create_Qualifier';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_return_status         VARCHAR2(1);

    l_seed_qual_rec         JTF_QUALIFIER_PUB.Seed_Qual_Rec_Type;
    l_seed_qual_out_rec     JTF_QUALIFIER_PUB.Seed_Qual_Out_Rec_Type;

    l_qual_usgs_rec         JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type;
    l_qual_usgs_out_rec     JTF_QUALIFIER_PUB.Qual_Usgs_All_Out_Rec_Type;

    /* variable for qualifier disable eligibility test */
    l_qualifier_used        VARCHAR2(30);

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT CREATE_QUALIFIER_PVT;

    -- Standard call to check for call compatability
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'PVT Create Qual: Start');
        FND_MSG_PUB.Add;
    END IF;


    -- ******************************************************************
    -- API BODY START
    -- ******************************************************************

    --  Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Seeded Qualifier record doesn't have any default values, so
    -- just initialise local variable to value of variable passed in as
    -- a parameter to this procedure
    l_seed_qual_rec     :=  p_seed_qual_rec;

    -- Converts missing items' values to default values in Qualifier Usages record
    convert_miss_qual_usgs_rec (p_qual_usgs_rec, l_qual_usgs_rec);

    -- Check if any territories are using this qualifier before disabling it.
    IF l_qual_usgs_rec.enabled_flag = 'N' THEN
            check_qualifier_usage (l_qual_usgs_rec.qual_usg_id, l_qualifier_used);
    END IF;
    IF l_qualifier_used = 'TRUE' THEN
        -- qualifier being used and cannot be diabled
        RAISE FND_API.G_EXC_ERROR;

    END IF;

    IF  p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

        -- Debug message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            FND_MESSAGE.Set_Name('JTF', 'PVTQUAL API:Validate Rec');
            FND_MSG_PUB.ADD;
        END IF;


        -- validate the seeded qualifier record
        validate_seed_qual_rec ( l_seed_qual_rec,
                                 JTF_CTM_UTILITY_PVT.G_CREATE,
                                 p_validation_level,
                                 l_return_status);


        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

         -- validate the qualifier usage record
        validate_qual_usgs_rec ( l_qual_usgs_rec,
                                 JTF_CTM_UTILITY_PVT.G_CREATE,
                                 p_validation_level,
                                 l_return_status);

         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;

    END IF; -- End of Record Validation


    -- Process Seeded Qualifier Record
    ----------------------------------

    -- Debug message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        FND_MESSAGE.Set_Name('JTF', 'PVT QUALIFIER API:');
        FND_MSG_PUB.ADD;
    END IF;

    -- Insert seeded qualifier record into database
    create_seed_qual_record ( l_seed_qual_rec,
                              l_seed_qual_out_rec);

    l_return_status := l_seed_qual_out_rec.return_status;


     --                    '  l_seeded_qual_id = '|| TO_CHAR(l_seed_qual_out_rec.seeded_qual_id));

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Process Qualifier Usages Record
    ----------------------------------

    -- Debug message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        FND_MESSAGE.Set_Name('JTF', 'PVT API: Ins');
        FND_MSG_PUB.ADD;
    END IF;

    create_qual_usgs_record ( l_seed_qual_out_rec.seeded_qual_id,
                              l_qual_usgs_rec,
                              l_qual_usgs_out_rec);

     l_return_status := l_qual_usgs_out_rec.return_status;



     --                    '  l_qual_usg_id = '|| TO_CHAR(l_qual_usgs_out_rec.qual_usg_id));


    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- save the returned seeded qualifer id, qualifier usage id, and status
    x_seed_qual_rec.seeded_qual_id := l_seed_qual_out_rec.seeded_qual_id;
    x_qual_usgs_rec.qual_usg_id := l_qual_usgs_out_rec.qual_usg_id;
    x_return_status := l_return_status;

-- *************************************************************************************
-- API BODY END
-- *************************************************************************************


    -- Success Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) AND
       l_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
        FND_MESSAGE.Set_Name('JTF', 'API_SUCCESS');
        FND_MESSAGE.Set_Token('ROW', 'JTF_QUALIFIER', TRUE);
        FND_MSG_PUB.Add;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'PVT Create Qual API: End');
        FND_MSG_PUB.Add;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      ( p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
      );

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO CREATE_QUALIFIER_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        FND_MSG_PUB.Count_And_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
        );


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO CREATE_QUALIFIER_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
        );


    WHEN OTHERS THEN
        ROLLBACK TO CREATE_QUALIFIER_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
        THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
        END IF;

        FND_MSG_PUB.Count_And_Get
        ( p_count         =>      x_msg_count,
          p_data          =>      x_msg_data
        );

END;


--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Update_Qualifier
--    Type      : PRIVATE
--    Function  : To update existing qualifiers
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name         Data Type                                Default
--      p_api_version          NUMBER
--      p_Seed_Qual_Rec        JTF_QUALIFIER_PUB.Seed_Qual_Rec_Type     JTF_QUALIFIER_PUB.G_MISS_SEED_QUAL_REC
--      p_Qual_Usgs_Rec        JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type JTF_QUALIFIER_PUB.G_MISS_QUAL_USGS_ALL_REC
--
--      Optional
--      Parameter Name         Data Type                                Default
--      P_Init_Msg_List        VARCHAR2                                 FND_API.G_FALSE
--      P_Commit               VARCHAR2                                 FND_API.G_FALSE
--      p_validation_level     VARCHAR2                                 FND_API.G_VALID_LEVEL_FULL
--
--     OUT     :
--      Parameter Name         Data Type                                Default
--      x_Return_Status        VARCHAR2(1)
--      x_Msg_Count            NUMBER
--      x_Msg_Data             VARCHAR2(2000)
--      x_Seed_Qual_Rec        Seed_Qual_Out_Rec_Type,
--      x_Qual_Usgs_Rec        Qual_Usgs_All_Out_Rec_Type);
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Update_Qualifier
(p_api_version         IN    NUMBER,
 p_Init_Msg_List       IN    VARCHAR2 := FND_API.G_FALSE,
 p_Commit              IN    VARCHAR2 := FND_API.G_FALSE,
 p_validation_level    IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
 x_Return_Status       OUT NOCOPY   VARCHAR2,
 x_Msg_Count           OUT NOCOPY   NUMBER,
 x_Msg_Data            OUT NOCOPY   VARCHAR2,
 p_Seed_Qual_Rec       IN    JTF_QUALIFIER_PUB.Seed_Qual_Rec_Type         := JTF_QUALIFIER_PUB.G_MISS_SEED_QUAL_REC,
 p_Qual_Usgs_Rec       IN    JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type     := JTF_QUALIFIER_PUB.G_MISS_QUAL_USGS_ALL_REC,
 x_Seed_Qual_Rec       OUT NOCOPY   JTF_QUALIFIER_PUB.Seed_Qual_Out_Rec_Type,
 x_Qual_Usgs_Rec       OUT NOCOPY   JTF_QUALIFIER_PUB.Qual_Usgs_All_Out_Rec_Type
)
IS
    l_api_name              CONSTANT VARCHAR2(30) := 'Update_Qualifier';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_return_status         VARCHAR2(1);

    /* local scratch records */
    l_seed_qual_rec         JTF_QUALIFIER_PUB.Seed_Qual_Rec_Type;
    l_seed_qual_out_rec     JTF_QUALIFIER_PUB.Seed_Qual_Out_Rec_Type;

    l_qual_usgs_rec         JTF_QUALIFIER_PUB.Qual_Usgs_All_Rec_Type;
    l_qual_usgs_out_rec     JTF_QUALIFIER_PUB.Qual_Usgs_All_Out_Rec_Type;

BEGIN


    -- Standard Start of API savepoint
    SAVEPOINT UPDATE_QUALIFIER_PVT;

    -- Standard call to check for call compatability
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'PVT UpdateQual API: Start');
        FND_MSG_PUB.Add;
    END IF;


    -- ******************************************************************
    -- API BODY START
    -- ******************************************************************

    --  Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Seeded Qualifier record doesn't have any default values, so
    -- just initialise local variable to value of variable passed in as
    -- a parameter to this procedure
    l_seed_qual_rec     :=  p_seed_qual_rec;


     -- Converts missing items' values to default values in Qualifier Usages record
    convert_miss_qual_usgs_rec (p_qual_usgs_rec, l_qual_usgs_rec);


    IF  p_validation_level > FND_API.G_VALID_LEVEL_NONE THEN

        -- Debug message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            FND_MESSAGE.Set_Name('JTF', 'PVT QUAL API: Valdte Record');
            FND_MSG_PUB.ADD;
        END IF;

        -- validate the seeded qualifier record
        validate_seed_qual_rec ( l_seed_qual_rec,
                                 JTF_CTM_UTILITY_PVT.G_UPDATE,
                                 p_validation_level,
                                 l_return_status);


        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;




         -- validate the qualifier usage record
        validate_qual_usgs_rec ( l_qual_usgs_rec,
                                 JTF_CTM_UTILITY_PVT.G_UPDATE,
                                 p_validation_level,
                                 l_return_status);



         IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
        END IF;



    END IF; -- End of Record Validation


    -- Process Seeded Qualifier Record
    ----------------------------------

    -- Debug message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        FND_MESSAGE.Set_Name('JTF', 'PVTQUAL API:Updte SeedQualRec');
        FND_MSG_PUB.ADD;
    END IF;

    -- Update seeded qualifier record into database
    update_seed_qual_record ( l_seed_qual_rec,
                              l_seed_qual_out_rec);
    l_return_status := l_seed_qual_out_rec.return_status;


    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Process Qualifier Usages Record
    ----------------------------------

    -- Debug message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        FND_MESSAGE.Set_Name('JTF', 'PVTQUAL API:Update QualUsgRec');
        FND_MSG_PUB.ADD;
    END IF;

    update_qual_usgs_record ( l_qual_usgs_rec,
                              l_qual_usgs_out_rec);

    l_return_status := l_qual_usgs_out_rec.return_status;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- save the returned seeded qualifer id, qualifier usage id, and status
    x_seed_qual_rec.seeded_qual_id := l_seed_qual_out_rec.seeded_qual_id;
    x_qual_usgs_rec.qual_usg_id := l_qual_usgs_out_rec.qual_usg_id;
    x_return_status := l_return_status;

-- *************************************************************************************
-- API BODY END
-- *************************************************************************************


    -- Success Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) AND
       l_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
        FND_MESSAGE.Set_Name('JTF', 'API_SUCCESS');
        FND_MESSAGE.Set_Token('ROW', 'JTF_QUALIFIER', TRUE);
        FND_MSG_PUB.Add;
    END IF;



    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'PVT Update Qual API: End');
        FND_MSG_PUB.Add;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      ( p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
      );

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO UPDATE_QUALIFIER_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        FND_MSG_PUB.Count_And_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
        );


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO UPDATE_QUALIFIER_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
        );


    WHEN OTHERS THEN
        ROLLBACK TO UPDATE_QUALIFIER_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
        THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
        END IF;

        FND_MSG_PUB.Count_And_Get
        ( p_count         =>      x_msg_count,
          p_data          =>      x_msg_data
        );

END Update_Qualifier;


--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Delete_Qualifier
--    Type      : PRIVATE
--    Function  : To delete an existing qualifiers
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name         Data Type            Default
--      p_api_version          NUMBER
--      p_Seeded_Qual_Id       NUMBER               FND_API.G_MISS_NUM
--      p_Qual_Usgs_Id         NUMBER               FND_API.G_MISS_NUM
--
--      Optional
--      Parameter Name         Data Type            Default
--      P_Init_Msg_List        VARCHAR2             FND_API.G_FALSE
--      P_Commit               VARCHAR2             FND_API.G_FALSE
--      p_validation_level     VARCHAR2             FND_API.G_VALID_LEVEL_FULL
--
--     OUT     :
--      Parameter Name         Data Type            Default
--      x_Return_Status        VARCHAR2(1)
--      x_Msg_Count            NUMBER
--      x_Msg_Data             VARCHAR2(2000)
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Delete_Qualifier
(p_api_version         IN    NUMBER,
 p_Init_Msg_List       IN    VARCHAR2 := FND_API.G_FALSE,
 p_Commit              IN    VARCHAR2 := FND_API.G_FALSE,
 p_validation_level    IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
 x_Return_Status       OUT NOCOPY   VARCHAR2,
 x_Msg_Count           OUT NOCOPY   NUMBER,
 x_Msg_Data            OUT NOCOPY   VARCHAR2,
 p_Seeded_Qual_Id      IN    NUMBER   := FND_API.G_MISS_NUM,
 p_Qual_Usg_Id         IN    NUMBER   := FND_API.G_MISS_NUM
)
IS
    l_api_name              CONSTANT VARCHAR2(30) := 'Delete_Qualifier';
    l_api_version           CONSTANT NUMBER       := 1.0;
    l_return_status         VARCHAR2(1);

    l_seeded_qual_id        NUMBER;
    l_qual_usg_id           NUMBER;

BEGIN




    -- Standard Start of API savepoint
    SAVEPOINT DELETE_QUALIFIER_PVT;

    -- Standard call to check for call compatability
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;


    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'Delete Qualifier PVT: Start');
        FND_MSG_PUB.Add;
    END IF;

    -- ******************************************************************
    -- API BODY START
    -- ******************************************************************

    --  Initialize API return status to success
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    /* initialise local variable to value of variable passed in as
    ** a parameter to this procedure
    */
    l_seeded_qual_id     :=  p_seeded_qual_id;
    l_qual_usg_id        :=  p_qual_usg_id;



    -- CHECK IF RECORDS SHOULD BE DELETED
    --
    -- seeded flag <> Y
    -- cannot delete seeded_qual if more that one qual_usg exists for that qualifier
    -- cannot delete qualifier if it is being used in a territory or territory type definition
    /* check if record should be deleted */
    is_qualifier_delete_allowed ( l_seeded_qual_id, l_qual_usg_id , l_return_status);



    IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN


        RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Process Seeded Qualifier Record
    ----------------------------------

    -- Debug message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        FND_MESSAGE.Set_Name('JTF', 'Delete Qualifier PVT: Debug1');
        FND_MSG_PUB.ADD;
    END IF;



    -- Update seeded qualifier record into database
    delete_seed_qual_record ( l_seeded_qual_id,
                              l_return_status);




    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Process Qualifier Usages Record
    ----------------------------------

    -- Debug message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        FND_MESSAGE.Set_Name('JTF', 'Delete Qualifier PVT: Debug2');
        FND_MSG_PUB.ADD;
    END IF;



    delete_qual_usgs_record ( l_qual_usg_id,
                              l_return_status);


    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    /* save return status */
    x_return_status := l_return_status;

-- *************************************************************************************
-- API BODY END
-- *************************************************************************************


    -- Success Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) AND
       l_return_status = FND_API.G_RET_STS_SUCCESS
    THEN
        FND_MESSAGE.Set_Name('JTF', 'API_SUCCESS');
        FND_MESSAGE.Set_Token('ROW', 'JTF_QUALIFIER', TRUE);
        FND_MSG_PUB.Add;
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean ( p_commit )
    THEN
        COMMIT WORK;
    END IF;

    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'PVT Delete Qual API: End');
        FND_MSG_PUB.Add;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      ( p_count           =>      x_msg_count,
        p_data            =>      x_msg_data
      );

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO DELETE_QUALIFIER_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR ;

        FND_MSG_PUB.Count_And_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
        );


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO DELETE_QUALIFIER_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
        );


    WHEN OTHERS THEN
        ROLLBACK TO DELETE_QUALIFIER_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
        THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
        END IF;

        FND_MSG_PUB.Count_And_Get
        ( p_count         =>      x_msg_count,
          p_data          =>      x_msg_data
        );

END;

END JTF_QUALIFIER_PVT;  -- Package Body JTF_QUALIFIER_PVT

/
