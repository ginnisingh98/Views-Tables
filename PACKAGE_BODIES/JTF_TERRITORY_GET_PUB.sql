--------------------------------------------------------
--  DDL for Package Body JTF_TERRITORY_GET_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERRITORY_GET_PUB" AS
/* $Header: jtfptrgb.pls 120.3.12010000.4 2009/04/28 11:36:55 ppillai ship $ */
---------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERRITORY_GET_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager private api's.
--      This package is a public API for retrieving
--      related information from JTF tables.
--      It contains specification for pl/sql records and tables
--      and the Public territory related API's.
--
--      Procedures:
--
--
--    NOTES
--      This package is available for private use only
--
--    HISTORY
--      07/15/99   JDOCHERT         Created
--      12/22/99   VNEDUNGA         Making changes to confirm
--                                  to JTF_TERR_RSC
--      05/03/00   VNEDUNGA         Fxing get_esclation and get_Parent
--                                  API's
--      05/03/01   ARPATEL          Specify table entries for
--                                  x_QualifyingRsc_out_tbl in proc
--                                  Get_Escalation_TerrMembers
--      07/16/01   ARPATEL          Changed to a 'for loop' construct in Get_Escalation_TerrMembers
--      08/22/01   ARPATEL          Added JTF_TERR_ALL start/end date checks in cursor C_GetTerrRsc
--
--    End of Comments
G_FILE_NAME     CONSTANT VARCHAR2(12) := 'jtfptrgb.pls';

G_USER_ID       NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID      NUMBER := FND_GLOBAL.CONC_LOGIN_ID;


PROCEDURE gen_init_sql ( x_select_clause OUT NOCOPY VARCHAR2
                       , x_from_clause   OUT NOCOPY VARCHAR2
                       , x_where_clause  OUT NOCOPY VARCHAR2 )
IS
   l_proc_name   VARCHAR2(30) := 'Gen_Init_SQL';

BEGIN

    /* Debug Message */

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;


    /* build initial part of select clause */
    x_select_clause := 'SELECT ' ||
                       'JTOV.TERR_ID, ' ||
                       'JTOV.NAME, ' ||
                       'JTOV.TERR_USAGE, ' ||
                       'JTOV.START_DATE_ACTIVE, ' ||
                       'JTOV.END_DATE_ACTIVE, ' ||
                       'JTOV.TEMPLATE_FLAG, ' ||
                       'JTOV.ESCALATION_TERRITORY_FLAG, ' ||
                       'JTOV.PARENT_TERR_NAME, ' ||
                       'JTOV.TERR_TYPE_NAME ';

    /* build initial part of FROM clause
    ** (smallest tables first from right-hand side)
    */
    x_from_clause := 'JTF_TERR_USGS JTUA, ' ||
                     'JTF_TERR_OVERVIEW_V JTOV, ' ||
                     'JTF_SOURCES JSE ';

    /* build WHERE clause */
    x_where_clause :=  ' WHERE JTUA.TERR_ID = JTOV.TERR_ID ' ||
                       ' AND JTUA.SOURCE_ID = JSE.SOURCE_ID ';

    /* Debug Message */

    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;


END gen_init_sql;


PROCEDURE define_dsql_columns ( p_dsql_csr          IN NUMBER,
                                p_terr_header_rec   IN Terr_Header_Rec_Type )
IS
   l_proc_name   VARCHAR2(30) := 'Define_DSQL_Columns';

BEGIN

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

    /* define all columns */
    dbms_sql.define_column(p_dsql_csr, 1, p_terr_header_rec.TERR_ID);
    dbms_sql.define_column(p_dsql_csr, 2, p_terr_header_rec.TERR_NAME, 2000);
    dbms_sql.define_column(p_dsql_csr, 3, p_terr_header_rec.TERR_USAGE, 30);
    dbms_sql.define_column(p_dsql_csr, 4, p_terr_header_rec.START_DATE_ACTIVE);
    dbms_sql.define_column(p_dsql_csr, 5, p_terr_header_rec.END_DATE_ACTIVE);
    dbms_sql.define_column(p_dsql_csr, 6, p_terr_header_rec.TEMPLATE_FLAG, 1);
    dbms_sql.define_column(p_dsql_csr, 7, p_terr_header_rec.ESCALATION_TERRITORY_FLAG, 1);
    dbms_sql.define_column(p_dsql_csr, 8, p_terr_header_rec.PARENT_TERR_NAME, 2000);
    dbms_sql.define_column(p_dsql_csr, 9, p_terr_header_rec.TERR_TYPE_NAME, 60);

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

END define_dsql_columns;


PROCEDURE get_dsql_column_values ( p_dsql_csr          IN NUMBER,
                                   x_terr_header_rec   OUT NOCOPY Terr_Header_Rec_Type )
IS
   l_proc_name   VARCHAR2(30) := 'Get_DSQL_Column_Values';

BEGIN

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

    /* get all columns */
    dbms_sql.column_value(p_dsql_csr, 1, x_terr_header_rec.TERR_ID);
    dbms_sql.column_value(p_dsql_csr, 2, x_terr_header_rec.TERR_NAME);
    dbms_sql.column_value(p_dsql_csr, 3, x_terr_header_rec.TERR_USAGE);
    dbms_sql.column_value(p_dsql_csr, 4, x_terr_header_rec.START_DATE_ACTIVE);
    dbms_sql.column_value(p_dsql_csr, 5, x_terr_header_rec.END_DATE_ACTIVE);
    dbms_sql.column_value(p_dsql_csr, 6, x_terr_header_rec.TEMPLATE_FLAG);
    dbms_sql.column_value(p_dsql_csr, 7, x_terr_header_rec.ESCALATION_TERRITORY_FLAG);
    dbms_sql.column_value(p_dsql_csr, 8, x_terr_header_rec.PARENT_TERR_NAME);
    dbms_sql.column_value(p_dsql_csr, 9, x_terr_header_rec.TERR_TYPE_NAME);


    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

END get_dsql_column_values;



PROCEDURE gen_where_clause (
    p_dsql_csr              IN      NUMBER,
    p_Terr_Rec              IN      Terr_Rec_Type,
    x_where_clause          IN OUT  NOCOPY VARCHAR2,
    x_use_flag              IN OUT  NOCOPY VARCHAR2
)
IS

    l_proc_name   VARCHAR2(30) := 'Gen_Where: Terr_Rec_Type';

    /* cursors to check if wildcard values '%' and '_' have been passed as item values */
    CURSOR c_chk_str1 (p_rec_item VARCHAR2) IS SELECT INSTR(p_rec_item, '%', 1, 1) FROM DUAL;
    CURSOR c_chk_str2 (p_rec_item VARCHAR2) IS SELECT INSTR(p_rec_item, '_', 1, 1) FROM DUAL;

    /* return values from cursors */
    str_csr1    NUMBER;
    str_csr2    NUMBER;

    l_operator      VARCHAR2(10);
    l_where_clause  VARCHAR2(2000);

BEGIN


    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

    --dbms_output.put_line('Value of p_TERR_rec.TERR_ID = '|| p_TERR_rec.terr_id);

    /* Hint: more search criteria can be added here to
    ** dynamically construct where clause at run time
    */
    IF ( (p_TERR_rec.TERR_ID IS NOT NULL) AND
         (p_TERR_rec.TERR_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTOV.TERR_ID = :p_TERR_1 ';

    END IF;

    IF ( (p_TERR_rec.NAME IS NOT NULL) AND
         (p_TERR_rec.NAME <> FND_API.G_MISS_CHAR) ) THEN

        --dbms_output.put_line('[2] Value of p_TERR_rec.NAME='|| p_TERR_rec.NAME);

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_rec.NAME);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

           -- check if item value contains '_' wildcard
           OPEN c_chk_str2 ( p_TERR_rec.NAME);
           FETCH c_chk_str2 INTO str_csr2;
           CLOSE c_chk_str2;

           IF ( str_csr2 <> 0 ) THEN
               l_operator := 'LIKE';
           ELSE
               l_operator := '=';
           END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTOV.NAME ' || l_operator || ' :p_TERR_12 ';

    END IF;


    IF ( (p_TERR_rec.START_DATE_ACTIVE IS NOT NULL) AND
         (p_TERR_rec.START_DATE_ACTIVE <> FND_API.G_MISS_DATE) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_rec.START_DATE_ACTIVE);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

           -- check if item value contains '_' wildcard
           OPEN c_chk_str2 ( p_TERR_rec.START_DATE_ACTIVE);
           FETCH c_chk_str2 INTO str_csr2;
           CLOSE c_chk_str2;

           IF ( str_csr2 <> 0 ) THEN
               l_operator := 'LIKE';
           ELSE
               l_operator := '=';
           END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTOV.START_DATE_ACTIVE ' ||
                          l_operator || ' :p_TERR_14 ';

    END IF;

    IF ( (p_TERR_rec.END_DATE_ACTIVE IS NOT NULL) AND
         (p_TERR_rec.END_DATE_ACTIVE <> FND_API.G_MISS_DATE) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_rec.END_DATE_ACTIVE);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

           -- check if item value contains '_' wildcard
           OPEN c_chk_str2 ( p_TERR_rec.END_DATE_ACTIVE);
           FETCH c_chk_str2 INTO str_csr2;
           CLOSE c_chk_str2;

           IF ( str_csr2 <> 0 ) THEN
               l_operator := 'LIKE';
           ELSE
               l_operator := '=';
           END IF;
        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTOV.END_DATE_ACTIVE ' ||
                          l_operator || ' :p_TERR_15 ';

    END IF;


    IF ( (p_TERR_rec.PARENT_TERRITORY_ID IS NOT NULL) AND
         (p_TERR_rec.PARENT_TERRITORY_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTOV.PARENT_TERRITORY_ID = :p_TERR_17 ';

    END IF;

    IF ( (p_TERR_rec.TERRITORY_TYPE_ID IS NOT NULL) AND
         (p_TERR_rec.TERRITORY_TYPE_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTOV.TERRITORY_TYPE_ID = :p_TERR_18 ';

    END IF;

    IF ( (p_TERR_rec.TEMPLATE_TERRITORY_ID IS NOT NULL) AND
         (p_TERR_rec.TEMPLATE_TERRITORY_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTOV.TEMPLATE_TERRITORY_ID = :p_TERR_19 ';

    END IF;

    IF ( (p_TERR_rec.TEMPLATE_FLAG IS NOT NULL) AND
         (p_TERR_rec.TEMPLATE_FLAG <> FND_API.G_MISS_CHAR) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTOV.TEMPLATE_FLAG ' ||
                          l_operator || ' :p_TERR_20 ';

    END IF;

    IF ( (p_TERR_rec.ESCALATION_TERRITORY_ID IS NOT NULL) AND
         (p_TERR_rec.ESCALATION_TERRITORY_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTOV.ESCALATION_TERRITORY_ID = :p_TERR_21 ';

    END IF;

    IF ( (p_TERR_rec.ESCALATION_TERRITORY_FLAG IS NOT NULL) AND
         (p_TERR_rec.ESCALATION_TERRITORY_FLAG <> FND_API.G_MISS_CHAR) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTOV.ESCALATION_TERRITORY_FLAG ' ||
                          l_operator || ' :p_TERR_22 ';

    END IF;

    IF ( (p_TERR_rec.OVERLAP_ALLOWED_FLAG IS NOT NULL) AND
         (p_TERR_rec.OVERLAP_ALLOWED_FLAG <> FND_API.G_MISS_CHAR) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTOV.OVERLAP_ALLOWED_FLAG ' ||
                          l_operator || ' :p_TERR_23 ';

    END IF;

    IF ( (p_TERR_rec.RANK IS NOT NULL) AND
         (p_TERR_rec.RANK <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTOV.RANK = :p_TERR_24 ';

    END IF;

    IF ( (p_TERR_rec.DESCRIPTION IS NOT NULL) AND
         (p_TERR_rec.DESCRIPTION <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_rec.DESCRIPTION);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

           -- check if item value contains '_' wildcard
           OPEN c_chk_str2 ( p_TERR_rec.DESCRIPTION);
           FETCH c_chk_str2 INTO str_csr2;
           CLOSE c_chk_str2;

           IF ( str_csr2 <> 0 ) THEN
               l_operator := 'LIKE';
           ELSE
               l_operator := '=';
           END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTOV.DESCRIPTION ' ||
                          l_operator || ' :p_TERR_25 ';

    END IF;

    IF ( (p_TERR_rec.PARENT_TERR_NAME IS NOT NULL) AND
         (p_TERR_rec.PARENT_TERR_NAME <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_rec.PARENT_TERR_NAME);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

           -- check if item value contains '_' wildcard
           OPEN c_chk_str2 ( p_TERR_rec.PARENT_TERR_NAME);
           FETCH c_chk_str2 INTO str_csr2;
           CLOSE c_chk_str2;

           IF ( str_csr2 <> 0 ) THEN
               l_operator := 'LIKE';
           ELSE
               l_operator := '=';
           END IF;

        END IF;


        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTOV.PARENT_TERR_NAME ' ||
                          l_operator || ' :p_TERR_26 ';

    END IF;

    IF ( (p_TERR_rec.ESCALATION_TERR_NAME IS NOT NULL) AND
         (p_TERR_rec.ESCALATION_TERR_NAME <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_rec.ESCALATION_TERR_NAME);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

           -- check if item value contains '_' wildcard
           OPEN c_chk_str2 ( p_TERR_rec.ESCALATION_TERR_NAME);
           FETCH c_chk_str2 INTO str_csr2;
           CLOSE c_chk_str2;

           IF ( str_csr2 <> 0 ) THEN
               l_operator := 'LIKE';
           ELSE
               l_operator := '=';
           END IF;
        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTOV.ESCALATION_TERR_NAME ' ||
                          l_operator || ' :p_TERR_27 ';

    END IF;

    IF ( (p_TERR_rec.TEMPLATE_TERR_NAME IS NOT NULL) AND
         (p_TERR_rec.TEMPLATE_TERR_NAME <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_rec.TEMPLATE_TERR_NAME);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

           -- check if item value contains '_' wildcard
           OPEN c_chk_str2 ( p_TERR_rec.TEMPLATE_TERR_NAME);
           FETCH c_chk_str2 INTO str_csr2;
           CLOSE c_chk_str2;

           IF ( str_csr2 <> 0 ) THEN
               l_operator := 'LIKE';
           ELSE
               l_operator := '=';
           END IF;
        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTOV.TEMPLATE_TERR_NAME ' ||
                          l_operator || ' :p_TERR_28 ';

    END IF;

    x_where_clause := x_where_clause || l_where_clause;

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

END gen_where_clause;


PROCEDURE gen_bind (
    p_dsql_csr              IN OUT      NOCOPY NUMBER,
    p_Terr_Rec              IN          Terr_Rec_Type
)
IS
    l_proc_name   VARCHAR2(30) := 'Gen_Bind: Terr_Rec_Type';
BEGIN

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;


    /* Hint: more search criteria can be added here to
    ** dynamically construct binds at run time
    */
    IF ( (p_TERR_rec.TERR_ID IS NOT NULL) AND
         (p_TERR_rec.TERR_ID <> FND_API.G_MISS_NUM) ) THEN

        --dbms_output.put_line('Binding p_TERR_rec.TERR_ID to :p_Terr_1');

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_1', p_TERR_rec.TERR_ID);

    END IF;

    IF ( (p_TERR_rec.NAME IS NOT NULL) AND
         (p_TERR_rec.NAME <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_12', p_TERR_rec.NAME);

    END IF;

    IF ( (p_TERR_rec.START_DATE_ACTIVE IS NOT NULL) AND
         (p_TERR_rec.START_DATE_ACTIVE <> FND_API.G_MISS_DATE) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_14', p_TERR_rec.START_DATE_ACTIVE);

    END IF;

    IF ( (p_TERR_rec.END_DATE_ACTIVE IS NOT NULL) AND
         (p_TERR_rec.END_DATE_ACTIVE <> FND_API.G_MISS_DATE) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_15', p_TERR_rec.END_DATE_ACTIVE);

    END IF;


    IF ( (p_TERR_rec.PARENT_TERRITORY_ID IS NOT NULL) AND
         (p_TERR_rec.PARENT_TERRITORY_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_17', p_TERR_rec.PARENT_TERRITORY_ID);

    END IF;

    IF ( (p_TERR_rec.TERRITORY_TYPE_ID IS NOT NULL) AND
         (p_TERR_rec.TERRITORY_TYPE_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_18', p_TERR_rec.TERRITORY_TYPE_ID);

    END IF;

    IF ( (p_TERR_rec.TEMPLATE_TERRITORY_ID IS NOT NULL) AND
         (p_TERR_rec.TEMPLATE_TERRITORY_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_19', p_TERR_rec.TEMPLATE_TERRITORY_ID);

    END IF;

    IF ( (p_TERR_rec.TEMPLATE_FLAG IS NOT NULL) AND
         (p_TERR_rec.TEMPLATE_FLAG <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_20', p_TERR_rec.TEMPLATE_FLAG);

    END IF;

    IF ( (p_TERR_rec.ESCALATION_TERRITORY_ID IS NOT NULL) AND
         (p_TERR_rec.ESCALATION_TERRITORY_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_21', p_TERR_rec.ESCALATION_TERRITORY_ID);

    END IF;

    IF ( (p_TERR_rec.ESCALATION_TERRITORY_FLAG IS NOT NULL) AND
         (p_TERR_rec.ESCALATION_TERRITORY_FLAG <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_22', p_TERR_rec.ESCALATION_TERRITORY_FLAG);

    END IF;

    IF ( (p_TERR_rec.OVERLAP_ALLOWED_FLAG IS NOT NULL) AND
         (p_TERR_rec.OVERLAP_ALLOWED_FLAG <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_23', p_TERR_rec.OVERLAP_ALLOWED_FLAG);

    END IF;

    IF ( (p_TERR_rec.RANK IS NOT NULL) AND
         (p_TERR_rec.RANK <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_24', p_TERR_rec.RANK);

    END IF;

    IF ( (p_TERR_rec.DESCRIPTION IS NOT NULL) AND
         (p_TERR_rec.DESCRIPTION <> FND_API.G_MISS_CHAR) ) THEN

       -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_25', p_TERR_rec.DESCRIPTION);

    END IF;

    IF ( (p_TERR_rec.PARENT_TERR_NAME IS NOT NULL) AND
         (p_TERR_rec.PARENT_TERR_NAME <> FND_API.G_MISS_CHAR) ) THEN

       -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_26', p_TERR_rec.PARENT_TERR_NAME);

    END IF;

    IF ( (p_TERR_rec.ESCALATION_TERR_NAME IS NOT NULL) AND
         (p_TERR_rec.ESCALATION_TERR_NAME <> FND_API.G_MISS_CHAR) ) THEN

       -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_27', p_TERR_rec.ESCALATION_TERR_NAME);

    END IF;

    IF ( (p_TERR_rec.TEMPLATE_TERR_NAME IS NOT NULL) AND
         (p_TERR_rec.TEMPLATE_TERR_NAME <> FND_API.G_MISS_CHAR) ) THEN

       -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_28', p_TERR_rec.TEMPLATE_TERR_NAME);

    END IF;

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

END gen_bind;

-----------------------------------------------------------------------
--     Territory Usages
-----------------------------------------------------------------------
PROCEDURE gen_where_clause (
    p_dsql_csr              IN      NUMBER,
    p_Terr_Usgs_Rec         IN      Terr_Usgs_Rec_Type,
    x_where_clause          IN OUT  NOCOPY VARCHAR2,
    x_use_flag              IN OUT  NOCOPY VARCHAR2
)
IS

    l_proc_name   VARCHAR2(30) := 'Gen_Where: Terr_Usgs';

    /* cursors to check if wildcard values '%' and '_' have been passed as item values */
    CURSOR c_chk_str1 (p_rec_item VARCHAR2) IS SELECT INSTR(p_rec_item, '%', 1, 1) FROM DUAL;
    CURSOR c_chk_str2 (p_rec_item VARCHAR2) IS SELECT INSTR(p_rec_item, '_', 1, 1) FROM DUAL;

    /* return values from cursors */
    str_csr1        NUMBER;
    str_csr2        NUMBER;

    l_operator      VARCHAR2(10);
    l_where_clause  VARCHAR2(2000);

BEGIN

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

    IF ( (p_TERR_USGS_rec.TERR_USG_ID IS NOT NULL) AND
         (p_TERR_USGS_rec.TERR_USG_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTUA.TERR_USG_ID = :p_TERR_USGS_1 ';

    END IF;

    IF ( (p_TERR_USGS_rec.TERR_ID IS NOT NULL) AND
         (p_TERR_USGS_rec.TERR_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTUA.TERR_ID = :p_TERR_USGS_7 ';

    END IF;

    IF ( (p_TERR_USGS_rec.SOURCE_ID IS NOT NULL) AND
         (p_TERR_USGS_rec.SOURCE_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTUA.SOURCE_ID = :p_TERR_USGS_8 ';

    END IF;

    IF ( (p_TERR_USGS_rec.USAGE IS NOT NULL) AND
         (p_TERR_USGS_rec.USAGE <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_USGS_rec.USAGE);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        --dbms_output.put_line('str_csr1 = ' || TO_CHAR(str_csr1));

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE
           -- check if item value contains '_' wildcard
           OPEN c_chk_str2 ( p_TERR_USGS_rec.USAGE);
           FETCH c_chk_str2 INTO str_csr2;
           CLOSE c_chk_str2;

           IF ( str_csr2 <> 0 ) THEN
            l_operator := 'LIKE';
           ELSE
            l_operator := '=';
           END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JSE.MEANING ' ||
                          l_operator ||' :p_TERR_USGS_9 ';

    END IF;

    x_where_clause := x_where_clause || l_where_clause;

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

END gen_where_clause;


PROCEDURE gen_bind (
    p_dsql_csr              IN      NUMBER,
    p_Terr_Usgs_Rec         IN      Terr_Usgs_Rec_Type
)
IS
    l_proc_name   VARCHAR2(30) := 'Gen_Bind: Terr_Usgs';

BEGIN

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

    IF ( (p_TERR_USGS_rec.TERR_USG_ID IS NOT NULL) AND
         (p_TERR_USGS_rec.TERR_USG_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_USGS_1', p_TERR_USGS_rec.TERR_USG_ID);

    END IF;

    IF ( (p_TERR_USGS_rec.TERR_ID IS NOT NULL) AND
         (p_TERR_USGS_rec.TERR_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_USGS_7', p_TERR_USGS_rec.TERR_ID);

    END IF;

    IF ( (p_TERR_USGS_rec.SOURCE_ID IS NOT NULL) AND
         (p_TERR_USGS_rec.SOURCE_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_USGS_8', p_TERR_USGS_rec.SOURCE_ID);

    END IF;

    IF ( (p_TERR_USGS_rec.USAGE IS NOT NULL) AND
         (p_TERR_USGS_rec.USAGE <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_USGS_9', p_TERR_USGS_rec.USAGE);

    END IF;

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

END gen_bind;


-----------------------------------------------------------------------
--     Territory Types
-----------------------------------------------------------------------
PROCEDURE gen_where_clause (
    p_dsql_csr              IN      NUMBER,
    p_Terr_Types_Rec        IN      Terr_Type_Rec_Type,
    x_where_clause          IN OUT  NOCOPY VARCHAR2,
    x_use_flag              IN OUT  NOCOPY VARCHAR2
)
IS

    l_proc_name   VARCHAR2(30) := 'Gen_Where: Terr_Type';

    /* cursors to check if wildcard values '%' and '_' have been passed as item values */
    CURSOR c_chk_str1 (p_rec_item VARCHAR2) IS SELECT INSTR(p_rec_item, '%', 1, 1) FROM DUAL;
    CURSOR c_chk_str2 (p_rec_item VARCHAR2) IS SELECT INSTR(p_rec_item, '_', 1, 1) FROM DUAL;

    /* return values from cursors */
    str_csr1        NUMBER;
    str_csr2        NUMBER;

    l_operator      VARCHAR2(10);
    l_where_clause  VARCHAR2(2000);

BEGIN

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

    IF ( (p_TERR_TYPES_rec.TERR_TYPE_ID IS NOT NULL) AND
         (p_TERR_TYPES_rec.TERR_TYPE_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTTA.TERR_TYPE_ID = :p_TERR_TYPES_1 ';

    END IF;

    IF ( (p_TERR_TYPES_rec.NAME IS NOT NULL) AND
         (p_TERR_TYPES_rec.NAME <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_TYPES_rec.NAME);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

           -- check if item value contains '_' wildcard
           OPEN c_chk_str2 ( p_TERR_TYPES_rec.NAME);
           FETCH c_chk_str2 INTO str_csr2;
           CLOSE c_chk_str2;

           IF ( str_csr2 <> 0 ) THEN
               l_operator := 'LIKE';
           ELSE
               l_operator := '=';
           END IF;
        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTTA.NAME ' ||
                          l_operator || ' :p_TERR_TYPES_8 ';

    END IF;

    IF ( (p_TERR_TYPES_rec.DESCRIPTION IS NOT NULL) AND
         (p_TERR_TYPES_rec.DESCRIPTION <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_TYPES_rec.DESCRIPTION);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

            -- check if item value contains '_' wildcard
            OPEN c_chk_str2 ( p_TERR_TYPES_rec.DESCRIPTION);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;

            IF ( str_csr2 <> 0 ) THEN
                l_operator := 'LIKE';
            ELSE
                l_operator := '=';
            END IF;
        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTTA.DESCRIPTION ' ||
                          l_operator || ' :p_TERR_TYPES_10 ';

    END IF;

    IF ( (p_TERR_TYPES_rec.START_DATE_ACTIVE IS NOT NULL) AND
         (p_TERR_TYPES_rec.START_DATE_ACTIVE <> FND_API.G_MISS_DATE) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_TYPES_rec.START_DATE_ACTIVE);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

            -- check if item value contains '_' wildcard
            OPEN c_chk_str2 ( p_TERR_TYPES_rec.START_DATE_ACTIVE);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;

            IF ( str_csr2 <> 0 ) THEN
                l_operator := 'LIKE';
            ELSE
                l_operator := '=';
            END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTTA.START_DATE_ACTIVE ' ||
                          l_operator || ' :p_TERR_TYPES_11 ';


    END IF;

    IF ( (p_TERR_TYPES_rec.END_DATE_ACTIVE IS NOT NULL) AND
         (p_TERR_TYPES_rec.END_DATE_ACTIVE <> FND_API.G_MISS_DATE) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_TYPES_rec.END_DATE_ACTIVE);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

            -- check if item value contains '_' wildcard
            OPEN c_chk_str2 ( p_TERR_TYPES_rec.END_DATE_ACTIVE);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;

            IF ( str_csr2 <> 0 ) THEN
                l_operator := 'LIKE';
            ELSE
                l_operator := '=';
            END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTTA.END_DATE_ACTIVE ' ||
                          l_operator || ' :p_TERR_TYPES_12 ';

    END IF;

    x_where_clause := x_where_clause || l_where_clause;

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

END gen_where_clause;


PROCEDURE gen_bind (
    p_dsql_csr              IN      NUMBER,
    p_Terr_Types_Rec        IN      Terr_Type_Rec_Type
)
IS
    l_proc_name   VARCHAR2(30) := 'Gen_Bind: Terr_Type';

BEGIN

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

    IF ( (p_TERR_TYPES_rec.TERR_TYPE_ID IS NOT NULL) AND
         (p_TERR_TYPES_rec.TERR_TYPE_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_TYPES_1', p_TERR_TYPES_rec.TERR_TYPE_ID);

    END IF;


    IF ( (p_TERR_TYPES_rec.NAME IS NOT NULL) AND
         (p_TERR_TYPES_rec.NAME <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_TYPES_8', p_TERR_TYPES_rec.NAME);

    END IF;


    IF ( (p_TERR_TYPES_rec.DESCRIPTION IS NOT NULL) AND
         (p_TERR_TYPES_rec.DESCRIPTION <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_TYPES_10', p_TERR_TYPES_rec.DESCRIPTION);

    END IF;

    IF ( (p_TERR_TYPES_rec.START_DATE_ACTIVE IS NOT NULL) AND
         (p_TERR_TYPES_rec.START_DATE_ACTIVE <> FND_API.G_MISS_DATE) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_TYPES_11', p_TERR_TYPES_rec.START_DATE_ACTIVE);

    END IF;

    IF ( (p_TERR_TYPES_rec.END_DATE_ACTIVE IS NOT NULL) AND
         (p_TERR_TYPES_rec.END_DATE_ACTIVE <> FND_API.G_MISS_DATE) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_TYPES_12', p_TERR_TYPES_rec.END_DATE_ACTIVE);

    END IF;

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

END gen_bind;


-----------------------------------------------------------------------
--     Territory Qualifier Type Usages
-----------------------------------------------------------------------
PROCEDURE gen_where_clause (
    p_dsql_csr              IN      NUMBER,
    p_Terr_QType_Usgs_Rec   IN      Terr_QType_Usgs_Rec_Type,
    x_where_clause          IN OUT  NOCOPY VARCHAR2,
    x_use_flag              IN OUT  NOCOPY VARCHAR2
)
IS

    l_proc_name   VARCHAR2(30) := 'Gen_Where: Terr_QType_Usgs';

    /* cursors to check if wildcard values '%' and '_' have been passed as item values */
    CURSOR c_chk_str1 (p_rec_item VARCHAR2) IS SELECT INSTR(p_rec_item, '%', 1, 1) FROM DUAL;
    CURSOR c_chk_str2 (p_rec_item VARCHAR2) IS SELECT INSTR(p_rec_item, '_', 1, 1) FROM DUAL;

    /* return values from cursors */
    str_csr1        NUMBER;
    str_csr2        NUMBER;

    l_operator      VARCHAR2(10);
    l_where_clause  VARCHAR2(2000);

BEGIN

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

    IF ( (p_TERR_QTYPE_USGS_REC.TERR_QTYPE_USG_ID IS NOT NULL) AND
         (p_TERR_QTYPE_USGS_REC.TERR_QTYPE_USG_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTTV.TERR_QTYPE_USG_ID = :p_TERR_QTYPE_USGS_1 ';

    END IF;

    IF ( (p_TERR_QTYPE_USGS_REC.TERR_ID IS NOT NULL) AND
         (p_TERR_QTYPE_USGS_REC.TERR_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTTV.TERR_ID = :p_TERR_QTYPE_USGS_7 ';

    END IF;

    IF ( (p_TERR_QTYPE_USGS_REC.QUAL_TYPE_USG_ID IS NOT NULL) AND
         (p_TERR_QTYPE_USGS_REC.QUAL_TYPE_USG_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTTV.TERR_ID = :p_TERR_QTYPE_USGS_8 ';

    END IF;

    IF ( (p_TERR_QTYPE_USGS_REC.SOURCE_ID IS NOT NULL) AND
         (p_TERR_QTYPE_USGS_REC.SOURCE_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTTV.SOURCE_ID = :p_TERR_QTYPE_USGS_10 ';

    END IF;

    IF ( (p_TERR_QTYPE_USGS_REC.QUAL_TYPE_ID IS NOT NULL) AND
         (p_TERR_QTYPE_USGS_REC.QUAL_TYPE_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTTV.QUAL_TYPE_ID = :p_TERR_QTYPE_USGS_11 ';

    END IF;

    IF ( (p_TERR_QTYPE_USGS_REC.QUALIFIER_TYPE_NAME IS NOT NULL) AND
         (p_TERR_QTYPE_USGS_REC.QUALIFIER_TYPE_NAME <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_QTYPE_USGS_REC.QUALIFIER_TYPE_NAME);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

            -- check if item value contains '_' wildcard
            OPEN c_chk_str2 ( p_TERR_QTYPE_USGS_REC.QUALIFIER_TYPE_NAME);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;

            IF ( str_csr2 <> 0 ) THEN
                l_operator := 'LIKE';
            ELSE
                l_operator := '=';
            END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause ||
                          'AND JTTV.QUALIFIER_TYPE_NAME = :p_TERR_QTYPE_USGS_12 ';

    END IF;

    IF ( (p_TERR_QTYPE_USGS_REC.QUALIFIER_TYPE_DESCRIPTION IS NOT NULL) AND
         (p_TERR_QTYPE_USGS_REC.QUALIFIER_TYPE_DESCRIPTION <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_QTYPE_USGS_REC.QUALIFIER_TYPE_DESCRIPTION);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

            -- check if item value contains '_' wildcard
            OPEN c_chk_str2 ( p_TERR_QTYPE_USGS_REC.QUALIFIER_TYPE_DESCRIPTION);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;

            IF ( str_csr2 <> 0 ) THEN
                l_operator := 'LIKE';
            ELSE
                l_operator := '=';
            END IF;
        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause ||
                          'AND JTTV.QUALIFIER_TYPE_DESCRIPTION = :p_TERR_QTYPE_USGS_13 ';

    END IF;

    x_where_clause := x_where_clause || l_where_clause;

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

END gen_where_clause;


PROCEDURE gen_bind (
    p_dsql_csr              IN      NUMBER,
    p_Terr_QType_Usgs_Rec   IN      Terr_QType_Usgs_Rec_Type
)
IS

    l_proc_name   VARCHAR2(30) := 'Gen_Bind: Terr_QType_Usgs';

BEGIN

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;


    IF ( (p_TERR_QTYPE_USGS_REC.TERR_QTYPE_USG_ID IS NOT NULL) AND
         (p_TERR_QTYPE_USGS_REC.TERR_QTYPE_USG_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_QTYPE_USGS_1', p_TERR_QTYPE_USGS_rec.TERR_QTYPE_USG_ID);

    END IF;

    IF ( (p_TERR_QTYPE_USGS_REC.TERR_ID IS NOT NULL) AND
         (p_TERR_QTYPE_USGS_REC.TERR_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_QTYPE_USGS_7', p_TERR_QTYPE_USGS_rec.TERR_ID);

    END IF;

    IF ( (p_TERR_QTYPE_USGS_REC.QUAL_TYPE_USG_ID IS NOT NULL) AND
         (p_TERR_QTYPE_USGS_REC.QUAL_TYPE_USG_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_QTYPE_USGS_8', p_TERR_QTYPE_USGS_rec.QUAL_TYPE_USG_ID);

    END IF;

    IF ( (p_TERR_QTYPE_USGS_REC.SOURCE_ID IS NOT NULL) AND
         (p_TERR_QTYPE_USGS_REC.SOURCE_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_QTYPE_USGS_10', p_TERR_QTYPE_USGS_rec.SOURCE_ID);

    END IF;

    IF ( (p_TERR_QTYPE_USGS_REC.QUAL_TYPE_ID IS NOT NULL) AND
         (p_TERR_QTYPE_USGS_REC.QUAL_TYPE_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_QTYPE_USGS_11', p_TERR_QTYPE_USGS_rec.QUAL_TYPE_ID);

    END IF;

    IF ( (p_TERR_QTYPE_USGS_REC.QUALIFIER_TYPE_NAME IS NOT NULL) AND
         (p_TERR_QTYPE_USGS_REC.QUALIFIER_TYPE_NAME <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_QTYPE_USGS_12', p_TERR_QTYPE_USGS_rec.QUALIFIER_TYPE_NAME);

    END IF;

    IF ( (p_TERR_QTYPE_USGS_REC.QUALIFIER_TYPE_DESCRIPTION IS NOT NULL) AND
         (p_TERR_QTYPE_USGS_REC.QUALIFIER_TYPE_DESCRIPTION <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_QTYPE_USGS_13', p_TERR_QTYPE_USGS_rec.QUALIFIER_TYPE_DESCRIPTION);

    END IF;


    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

END gen_bind;

-----------------------------------------------------------------------
--     Territory Qualifiers
-----------------------------------------------------------------------
PROCEDURE gen_where_clause (
    p_dsql_csr              IN      NUMBER,
    p_Terr_Qual_Rec         IN      Terr_Qual_Rec_Type,
    x_where_clause          IN OUT  NOCOPY VARCHAR2,
    x_use_flag              IN OUT  NOCOPY VARCHAR2
)
IS

    l_proc_name   VARCHAR2(30) := 'Gen_Where: Terr_Qual';

    /* cursors to check if wildcard values '%' and '_' have been passed as item values */
    CURSOR c_chk_str1 (p_rec_item VARCHAR2) IS SELECT INSTR(p_rec_item, '%', 1, 1) FROM DUAL;
    CURSOR c_chk_str2 (p_rec_item VARCHAR2) IS SELECT INSTR(p_rec_item, '_', 1, 1) FROM DUAL;

    /* return values from cursors */
    str_csr1        NUMBER;
    str_csr2        NUMBER;

    l_operator      VARCHAR2(10);
    l_where_clause  VARCHAR2(2000);

BEGIN

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;


    IF ( (p_TERR_QUAL_rec.TERR_QUAL_ID IS NOT NULL) AND
         (p_TERR_QUAL_rec.TERR_QUAL_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTQV.TERR_QUAL_ID = :p_TERR_QUAL_1 ';

    END IF;

    IF ( (p_TERR_QUAL_rec.TERR_ID IS NOT NULL) AND
         (p_TERR_QUAL_rec.TERR_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTQV.TERR_ID = :p_TERR_QUAL_7 ';

    END IF;

    IF ( (p_TERR_QUAL_rec.QUAL_USG_ID IS NOT NULL) AND
         (p_TERR_QUAL_rec.QUAL_USG_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTQV.QUAL_USG_ID = :p_TERR_QUAL_8 ';

    END IF;


    IF ( (p_TERR_QUAL_rec.OVERLAP_ALLOWED_FLAG IS NOT NULL) AND
         (p_TERR_QUAL_rec.OVERLAP_ALLOWED_FLAG <> FND_API.G_MISS_CHAR) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTQV.OVERLAP_ALLOWED_FLAG ' ||
                          l_operator || ' :p_TERR_QUAL_11 ';

    END IF;

    IF ( (p_TERR_QUAL_rec.QUALIFIER_MODE IS NOT NULL) AND
         (p_TERR_QUAL_rec.QUALIFIER_MODE <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_QUAL_rec.QUALIFIER_MODE);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

            -- check if item value contains '_' wildcard
            OPEN c_chk_str2 ( p_TERR_QUAL_rec.QUALIFIER_MODE);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;

            IF ( str_csr2 <> 0 ) THEN
                l_operator := 'LIKE';
            ELSE
                l_operator := '=';
            END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTQV.QUALIFIER_MODE '
                          || l_operator || ' :p_TERR_QUAL_13 ';

    END IF;


    IF ( (p_TERR_QUAL_rec.DISPLAY_TYPE IS NOT NULL) AND
         (p_TERR_QUAL_rec.DISPLAY_TYPE <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_QUAL_rec.DISPLAY_TYPE);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

            -- check if item value contains '_' wildcard
            OPEN c_chk_str2 ( p_TERR_QUAL_rec.DISPLAY_TYPE);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;

            IF ( str_csr2 <> 0 ) THEN
                l_operator := 'LIKE';
            ELSE
                l_operator := '=';
            END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTQV.DISPLAY_TYPE '
                          || l_operator || ' :p_TERR_QUAL_14 ';

    END IF;

    IF ( (p_TERR_QUAL_rec.LOV_SQL IS NOT NULL) AND
         (p_TERR_QUAL_rec.LOV_SQL <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_QUAL_rec.LOV_SQL);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

            -- check if item value contains '_' wildcard
            OPEN c_chk_str2 ( p_TERR_QUAL_rec.LOV_SQL);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;

            IF ( str_csr2 <> 0 ) THEN
                l_operator := 'LIKE';
            ELSE
                l_operator := '=';
            END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTQV.LOV_SQL '
                          || l_operator || ' :p_TERR_QUAL_15 ';

    END IF;


    IF ( (p_TERR_QUAL_rec.CONVERT_TO_ID_FLAG IS NOT NULL) AND
         (p_TERR_QUAL_rec.CONVERT_TO_ID_FLAG <> FND_API.G_MISS_CHAR) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTQV.CONVERT_TO_ID_FLAG = :p_TERR_QUAL_16 ';

    END IF;

    IF ( (p_TERR_QUAL_rec.QUAL_TYPE_ID IS NOT NULL) AND
         (p_TERR_QUAL_rec.QUAL_TYPE_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTQV.QUAL_TYPE_ID = :p_TERR_QUAL_17 ';

    END IF;

    IF ( (p_TERR_QUAL_rec.QUALIFIER_TYPE_NAME IS NOT NULL) AND
         (p_TERR_QUAL_rec.QUALIFIER_TYPE_NAME <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_QUAL_rec.QUALIFIER_TYPE_NAME);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

            -- check if item value contains '_' wildcard
            OPEN c_chk_str2 ( p_TERR_QUAL_rec.QUALIFIER_TYPE_NAME);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;

            IF ( str_csr2 <> 0 ) THEN
                l_operator := 'LIKE';
            ELSE
                l_operator := '=';
            END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTQV.QUALIFIER_TYPE_NAME '
                          || l_operator || ' :p_TERR_QUAL_18 ';

    END IF;

    IF ( (p_Terr_Qual_Rec.QUALIFIER_TYPE_DESCRIPTION IS NOT NULL) AND
         (p_Terr_Qual_Rec.QUALIFIER_TYPE_DESCRIPTION <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_QUAL_rec.QUALIFIER_TYPE_DESCRIPTION);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

            -- check if item value contains '_' wildcard
            OPEN c_chk_str2 ( p_TERR_QUAL_rec.QUALIFIER_TYPE_DESCRIPTION);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;

            IF ( str_csr2 <> 0 ) THEN
                l_operator := 'LIKE';
            ELSE
                l_operator := '=';
            END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTQV.QUALIFIER_TYPE_DESCRIPTION '
                          || l_operator || ' :p_TERR_QUAL_19 ';

    END IF;

    IF ( (p_TERR_QUAL_rec.QUALIFIER_NAME IS NOT NULL) AND
         (p_TERR_QUAL_rec.QUALIFIER_NAME <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_QUAL_rec.QUALIFIER_NAME);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        --dbms_output.put_line('Value of str_csr1='||TO_CHAR(str_csr1));

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

            -- check if item value contains '_' wildcard
            OPEN c_chk_str2 ( p_TERR_QUAL_rec.QUALIFIER_NAME);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;

            IF ( str_csr2 <> 0 ) THEN
                l_operator := 'LIKE';
            ELSE
                l_operator := '=';
            END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTQV.QUALIFIER_NAME '
                          || l_operator || ' :p_TERR_QUAL_20 ';

    END IF;

    x_where_clause := x_where_clause || l_where_clause;

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;


END  gen_where_clause;


PROCEDURE gen_bind (
    p_dsql_csr              IN      NUMBER,
    p_Terr_Qual_Rec         IN      Terr_Qual_Rec_Type
)
IS
    l_proc_name   VARCHAR2(30) := 'Gen_Bind: Terr_Qual';
BEGIN


    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

    IF ( (p_TERR_QUAL_rec.TERR_QUAL_ID IS NOT NULL) AND
         (p_TERR_QUAL_rec.TERR_QUAL_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_QUAL_1', p_TERR_QUAL_rec.TERR_QUAL_ID);

    END IF;

    IF ( (p_TERR_QUAL_rec.TERR_ID IS NOT NULL) AND
         (p_TERR_QUAL_rec.TERR_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_QUAL_7', p_TERR_QUAL_rec.TERR_ID);

    END IF;

    IF ( (p_TERR_QUAL_rec.QUAL_USG_ID IS NOT NULL) AND
         (p_TERR_QUAL_rec.QUAL_USG_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_QUAL_8', p_TERR_QUAL_rec.QUAL_USG_ID);

    END IF;

    IF ( (p_TERR_QUAL_rec.OVERLAP_ALLOWED_FLAG IS NOT NULL) AND
         (p_TERR_QUAL_rec.OVERLAP_ALLOWED_FLAG <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_QUAL_11', p_TERR_QUAL_rec.OVERLAP_ALLOWED_FLAG);

    END IF;

    IF ( (p_TERR_QUAL_rec.QUALIFIER_MODE IS NOT NULL) AND
         (p_TERR_QUAL_rec.QUALIFIER_MODE <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_QUAL_13', p_TERR_QUAL_rec.QUALIFIER_MODE);

    END IF;

    IF ( (p_TERR_QUAL_rec.DISPLAY_TYPE IS NOT NULL) AND
         (p_TERR_QUAL_rec.DISPLAY_TYPE <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_QUAL_14', p_TERR_QUAL_rec.DISPLAY_TYPE);

    END IF;

    IF ( (p_TERR_QUAL_rec.LOV_SQL IS NOT NULL) AND
         (p_TERR_QUAL_rec.LOV_SQL <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_QUAL_15', p_TERR_QUAL_rec.LOV_SQL);

    END IF;

    IF ( (p_TERR_QUAL_rec.CONVERT_TO_ID_FLAG IS NOT NULL) AND
         (p_TERR_QUAL_rec.CONVERT_TO_ID_FLAG <> FND_API.G_MISS_CHAR) ) THEN


        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_QUAL_16', p_TERR_QUAL_rec.CONVERT_TO_ID_FLAG);

    END IF;

    IF ( (p_TERR_QUAL_rec.QUAL_TYPE_ID IS NOT NULL) AND
         (p_TERR_QUAL_rec.QUAL_TYPE_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_QUAL_17', p_TERR_QUAL_rec.QUAL_TYPE_ID);

    END IF;

    IF ( (p_TERR_QUAL_rec.QUALIFIER_TYPE_NAME IS NOT NULL) AND
         (p_TERR_QUAL_rec.QUALIFIER_TYPE_NAME <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_QUAL_18', p_TERR_QUAL_rec.QUALIFIER_TYPE_NAME);

    END IF;

    IF ( (p_TERR_QUAL_rec.QUALIFIER_TYPE_DESCRIPTION IS NOT NULL) AND
         (p_TERR_QUAL_rec.QUALIFIER_TYPE_DESCRIPTION <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_QUAL_19', p_TERR_QUAL_rec.QUALIFIER_TYPE_DESCRIPTION);

    END IF;

    IF ( (p_TERR_QUAL_rec.QUALIFIER_NAME IS NOT NULL) AND
         (p_TERR_QUAL_rec.QUALIFIER_NAME <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_QUAL_20', p_TERR_QUAL_rec.QUALIFIER_NAME);

    END IF;

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

END  gen_bind;


-----------------------------------------------------------------------
--     Territory Values
-----------------------------------------------------------------------
PROCEDURE gen_where_clause (
    p_dsql_csr              IN      NUMBER,
    p_Terr_Values_Rec       IN      Terr_Values_Rec_Type,
    x_where_clause          IN OUT  NOCOPY VARCHAR2,
    x_use_flag              IN OUT  NOCOPY VARCHAR2
)
IS

    l_proc_name   VARCHAR2(30) := 'Gen_Where: Terr_Values';

    /* cursors to check if wildcard values '%' and '_' have been passed as item values */
    CURSOR c_chk_str1 (p_rec_item VARCHAR2) IS SELECT INSTR(p_rec_item, '%', 1, 1) FROM DUAL;
    CURSOR c_chk_str2 (p_rec_item VARCHAR2) IS SELECT INSTR(p_rec_item, '_', 1, 1) FROM DUAL;

    /* return values from cursors */
    str_csr1        NUMBER;
    str_csr2        NUMBER;

    l_operator      VARCHAR2(10);

    l_where_clause  VARCHAR(2000);

BEGIN

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

    IF ( (p_TERR_VALUES_rec.TERR_VALUE_ID IS NOT NULL) AND
         (p_TERR_VALUES_rec.TERR_VALUE_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTV.TERR_VALUE_ID = :p_TERR_VALUES_1 ';

    END IF;

    IF ( (p_TERR_VALUES_rec.TERR_QUAL_ID IS NOT NULL) AND
         (p_TERR_VALUES_rec.TERR_QUAL_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTV.TERR_QUAL_ID = :p_TERR_VALUES_7 ';

    END IF;

    IF ( (p_TERR_VALUES_rec.COMPARISON_OPERATOR IS NOT NULL) AND
         (p_TERR_VALUES_rec.COMPARISON_OPERATOR <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_VALUES_rec.COMPARISON_OPERATOR);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

            -- check if item value contains '_' wildcard
            OPEN c_chk_str2 ( p_TERR_VALUES_rec.COMPARISON_OPERATOR);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;

            IF ( str_csr2 <> 0 ) THEN
                l_operator := 'LIKE';
            ELSE
                l_operator := '=';
            END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTV.COMPARISON_OPERATOR ' ||
                          l_operator || ' :p_TERR_VALUES_9 ';

    END IF;

    IF ( (p_TERR_VALUES_rec.LOW_VALUE_CHAR IS NOT NULL) AND
         (p_TERR_VALUES_rec.LOW_VALUE_CHAR <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_VALUES_rec.LOW_VALUE_CHAR);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

            -- check if item value contains '_' wildcard
            OPEN c_chk_str2 ( p_TERR_VALUES_rec.LOW_VALUE_CHAR);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;

            IF ( str_csr2 <> 0 ) THEN
                l_operator := 'LIKE';
            ELSE
                l_operator := '=';
            END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTV.LOW_VALUE_CHAR ' ||
                          l_operator || ' :p_TERR_VALUES_10 ';

    END IF;

    IF ( (p_TERR_VALUES_rec.HIGH_VALUE_CHAR IS NOT NULL) AND
         (p_TERR_VALUES_rec.HIGH_VALUE_CHAR <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_VALUES_rec.HIGH_VALUE_CHAR);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

            -- check if item value contains '_' wildcard
            OPEN c_chk_str2 ( p_TERR_VALUES_rec.HIGH_VALUE_CHAR);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;

            IF ( str_csr2 <> 0 ) THEN
                l_operator := 'LIKE';
            ELSE
                l_operator := '=';
            END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTV.HIGH_VALUE_CHAR ' ||
                          l_operator || ' :p_TERR_VALUES_11 ';

    END IF;

    IF ( (p_TERR_VALUES_rec.LOW_VALUE_NUMBER IS NOT NULL) AND
         (p_TERR_VALUES_rec.LOW_VALUE_NUMBER <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTV.LOW_VALUE_NUMBER = :p_TERR_VALUES_12 ';

    END IF;

    IF ( (p_TERR_VALUES_rec.HIGH_VALUE_NUMBER IS NOT NULL) AND
         (p_TERR_VALUES_rec.HIGH_VALUE_NUMBER <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTV.HIGH_VALUE_NUMBER = :p_TERR_VALUES_13 ';

    END IF;


    IF ( (p_TERR_VALUES_rec.INTEREST_TYPE_ID IS NOT NULL) AND
         (p_TERR_VALUES_rec.INTEREST_TYPE_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTV.INTEREST_TYPE_ID = :p_TERR_VALUES_15 ';

    END IF;

    IF ( (p_TERR_VALUES_rec.PRIMARY_INTEREST_CODE_ID IS NOT NULL) AND
         (p_TERR_VALUES_rec.PRIMARY_INTEREST_CODE_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTV.PRIMARY_INTEREST_CODE_ID = :p_TERR_VALUES_16 ';

    END IF;

    IF ( (p_TERR_VALUES_rec.SECONDARY_INTEREST_CODE_ID IS NOT NULL) AND
         (p_TERR_VALUES_rec.SECONDARY_INTEREST_CODE_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        x_where_clause := x_where_clause ||
                          'AND JTV.SECONDARY_INTEREST_CODE_ID = :p_TERR_VALUES_17 ';

    END IF;

    IF ( (p_TERR_VALUES_rec.CURRENCY_CODE IS NOT NULL) AND
         (p_TERR_VALUES_rec.CURRENCY_CODE <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_VALUES_rec.CURRENCY_CODE);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

            -- check if item value contains '_' wildcard
            OPEN c_chk_str2 ( p_TERR_VALUES_rec.CURRENCY_CODE);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;

            IF ( str_csr2 <> 0 ) THEN
                l_operator := 'LIKE';
            ELSE
                l_operator := '=';
            END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTV.CURRENCY_CODE ' ||
                          l_operator || ' :p_TERR_VALUES_18 ';

    END IF;

    IF ( (p_TERR_VALUES_rec.ID_USED_FLAG IS NOT NULL) AND
         (p_TERR_VALUES_rec.ID_USED_FLAG <> FND_API.G_MISS_CHAR) ) THEN

        x_use_flag := 'Y';
        x_where_clause := x_where_clause || 'AND JTV.ID_USED_FLAG = :p_TERR_VALUES_19 ';

    END IF;

    IF ( (p_TERR_VALUES_rec.LOW_VALUE_CHAR_ID IS NOT NULL) AND
         (p_TERR_VALUES_rec.LOW_VALUE_CHAR_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        x_where_clause := x_where_clause || 'AND JTV.LOW_VALUE_CHAR_ID = :p_TERR_VALUES_20 ';

    END IF;

    x_where_clause := x_where_clause || l_where_clause;

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

END gen_where_clause;


/* bind Territory Value record items */
PROCEDURE gen_bind (
    p_dsql_csr              IN      NUMBER,
    p_Terr_Values_Rec       IN      Terr_Values_Rec_Type
)
IS

    l_proc_name   VARCHAR2(30) := 'Gen_Bind: Terr_Qual';

BEGIN

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

    IF ( (p_TERR_VALUES_rec.TERR_VALUE_ID IS NOT NULL) AND
         (p_TERR_VALUES_rec.TERR_VALUE_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_VALUES_1', p_TERR_VALUES_rec.TERR_VALUE_ID);

    END IF;

    IF ( (p_TERR_VALUES_rec.TERR_QUAL_ID IS NOT NULL) AND
         (p_TERR_VALUES_rec.TERR_QUAL_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_VALUES_7', p_TERR_VALUES_rec.TERR_QUAL_ID);

    END IF;

    IF ( (p_TERR_VALUES_rec.COMPARISON_OPERATOR IS NOT NULL) AND
         (p_TERR_VALUES_rec.COMPARISON_OPERATOR <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_VALUES_9', p_TERR_VALUES_rec.COMPARISON_OPERATOR);

    END IF;

    IF ( (p_TERR_VALUES_rec.LOW_VALUE_CHAR IS NOT NULL) AND
         (p_TERR_VALUES_rec.LOW_VALUE_CHAR <> FND_API.G_MISS_CHAR) ) THEN

        --dbms_output.put_line( 'Value of p_TERR_VALUES_rec.LOW_VALUE_CHAR = ' ||
        --                      p_TERR_VALUES_rec.LOW_VALUE_CHAR);

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_VALUES_10', p_TERR_VALUES_rec.LOW_VALUE_CHAR);

    END IF;

    IF ( (p_TERR_VALUES_rec.HIGH_VALUE_CHAR IS NOT NULL) AND
         (p_TERR_VALUES_rec.HIGH_VALUE_CHAR <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_VALUES_11', p_TERR_VALUES_rec.HIGH_VALUE_CHAR);

    END IF;

    IF ( (p_TERR_VALUES_rec.LOW_VALUE_NUMBER IS NOT NULL) AND
         (p_TERR_VALUES_rec.LOW_VALUE_NUMBER <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_VALUES_12', p_TERR_VALUES_rec.LOW_VALUE_NUMBER);

    END IF;

    IF ( (p_TERR_VALUES_rec.HIGH_VALUE_NUMBER IS NOT NULL) AND
         (p_TERR_VALUES_rec.HIGH_VALUE_NUMBER <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_VALUES_13', p_TERR_VALUES_rec.HIGH_VALUE_NUMBER);

    END IF;


    IF ( (p_TERR_VALUES_rec.INTEREST_TYPE_ID IS NOT NULL) AND
         (p_TERR_VALUES_rec.INTEREST_TYPE_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_VALUES_15', p_TERR_VALUES_rec.INTEREST_TYPE_ID);

    END IF;

    IF ( (p_TERR_VALUES_rec.PRIMARY_INTEREST_CODE_ID IS NOT NULL) AND
         (p_TERR_VALUES_rec.PRIMARY_INTEREST_CODE_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_VALUES_16', p_TERR_VALUES_rec.PRIMARY_INTEREST_CODE_ID);

    END IF;

    IF ( (p_TERR_VALUES_rec.SECONDARY_INTEREST_CODE_ID IS NOT NULL) AND
         (p_TERR_VALUES_rec.SECONDARY_INTEREST_CODE_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_VALUES_17', p_TERR_VALUES_rec.SECONDARY_INTEREST_CODE_ID);

    END IF;

    IF ( (p_TERR_VALUES_rec.CURRENCY_CODE IS NOT NULL) AND
         (p_TERR_VALUES_rec.CURRENCY_CODE <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_VALUES_18', p_TERR_VALUES_rec.CURRENCY_CODE);

    END IF;

    IF ( (p_TERR_VALUES_rec.ID_USED_FLAG IS NOT NULL) AND
         (p_TERR_VALUES_rec.ID_USED_FLAG <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_VALUES_19', p_TERR_VALUES_rec.ID_USED_FLAG);

    END IF;

    IF ( (p_TERR_VALUES_rec.LOW_VALUE_CHAR_ID IS NOT NULL) AND
         (p_TERR_VALUES_rec.LOW_VALUE_CHAR_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_VALUES_20', p_TERR_VALUES_rec.LOW_VALUE_CHAR_ID);

    END IF;

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

END gen_bind;



-----------------------------------------------------------------------
--     Territory Resources
-----------------------------------------------------------------------
PROCEDURE gen_where_clause (
    p_dsql_csr              IN      NUMBER,
    p_Terr_Rsc_Rec          IN      Terr_Rsc_Rec_Type,
    x_where_clause          IN OUT  NOCOPY VARCHAR2,
    x_use_flag              IN OUT  NOCOPY VARCHAR2
)
IS

    l_proc_name   VARCHAR2(30) := 'Gen_Where: Terr_Rsc';

    /* cursors to check if wildcard values '%' and '_' have been passed as item values */
    CURSOR c_chk_str1 (p_rec_item VARCHAR2) IS SELECT INSTR(p_rec_item, '%', 1, 1) FROM DUAL;
    CURSOR c_chk_str2 (p_rec_item VARCHAR2) IS SELECT INSTR(p_rec_item, '_', 1, 1) FROM DUAL;

    /* return values from cursors */
    str_csr1    NUMBER;
    str_csr2    NUMBER;

    l_operator  VARCHAR2(10);
    l_where_clause  VARCHAR2(2000);

BEGIN

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

    IF ( (p_TERR_RSC_rec.TERR_RSC_ID IS NOT NULL) AND
         (p_TERR_RSC_rec.TERR_RSC_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTRV.TERR_RSC_ID = :p_TERR_RSC_1 ';

    END IF;

    IF ( (p_TERR_RSC_rec.TERR_ID IS NOT NULL) AND
         (p_TERR_RSC_rec.TERR_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTRV.TERR_ID = :p_TERR_RSC_7 ';

    END IF;

    IF ( (p_TERR_RSC_rec.RESOURCE_ID IS NOT NULL) AND
         (p_TERR_RSC_rec.RESOURCE_ID <> FND_API.G_MISS_NUM) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTRV.RESOURCE_ID = :p_TERR_RSC_8 ';

    END IF;

    IF ( (p_TERR_RSC_rec.RESOURCE_TYPE IS NOT NULL) AND
         (p_TERR_RSC_rec.RESOURCE_TYPE <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_RSC_rec.RESOURCE_TYPE);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

            -- check if item value contains '_' wildcard
            OPEN c_chk_str2 ( p_TERR_RSC_rec.RESOURCE_TYPE);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;

            IF ( str_csr2 <> 0 ) THEN
                l_operator := 'LIKE';
            ELSE
                l_operator := '=';
            END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTRV.RESOURCE_TYPE ' ||
                          l_operator || ' :p_TERR_RSC_9 ';

    END IF;

    IF ( (p_TERR_RSC_rec.ROLE IS NOT NULL) AND
         (p_TERR_RSC_rec.ROLE <> FND_API.G_MISS_CHAR) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_RSC_rec.ROLE);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

            -- check if item value contains '_' wildcard
            OPEN c_chk_str2 ( p_TERR_RSC_rec.ROLE);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;

            IF ( str_csr2 <> 0 ) THEN
                l_operator := 'LIKE';
            ELSE
                l_operator := '=';
            END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTRV.ROLE ' ||
                          l_operator || ' :p_TERR_RSC_10 ';


    END IF;

    IF ( (p_TERR_RSC_rec.PRIMARY_CONTACT_FLAG IS NOT NULL) AND
         (p_TERR_RSC_rec.PRIMARY_CONTACT_FLAG <> FND_API.G_MISS_CHAR) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTRV.PRIMARY_CONTACT_FLAG = :p_TERR_RSC_11';

    END IF;

    IF ( (p_TERR_RSC_rec.START_DATE_ACTIVE IS NOT NULL) AND
         (p_TERR_RSC_rec.START_DATE_ACTIVE <> FND_API.G_MISS_DATE) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_RSC_rec.START_DATE_ACTIVE);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

            -- check if item value contains '_' wildcard
            OPEN c_chk_str2 ( p_TERR_RSC_rec.START_DATE_ACTIVE);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;

            IF ( str_csr2 <> 0 ) THEN
                l_operator := 'LIKE';
            ELSE
                l_operator := '=';
            END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTRV.START_DATE_ACTIVE ' ||
                          l_operator || ' :p_TERR_RSC_12 ';

    END IF;

    IF ( (p_TERR_RSC_rec.END_DATE_ACTIVE IS NOT NULL) AND
         (p_TERR_RSC_rec.END_DATE_ACTIVE <> FND_API.G_MISS_DATE) ) THEN

        -- check if item value contains '%' wildcard
        OPEN c_chk_str1 ( p_TERR_RSC_rec.END_DATE_ACTIVE);
        FETCH c_chk_str1 INTO str_csr1;
        CLOSE c_chk_str1;

        IF ( str_csr1 <> 0 ) THEN
            l_operator := 'LIKE';
        ELSE

            -- check if item value contains '_' wildcard
            OPEN c_chk_str2 ( p_TERR_RSC_rec.END_DATE_ACTIVE);
            FETCH c_chk_str2 INTO str_csr2;
            CLOSE c_chk_str2;

            IF ( str_csr2 <> 0 ) THEN
                l_operator := 'LIKE';
            ELSE
                l_operator := '=';
            END IF;

        END IF;

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTRV.END_DATE_ACTIVE ' ||
                          l_operator || ' :p_TERR_RSC_13 ';

    END IF;

    IF ( (p_TERR_RSC_rec.FULL_ACCESS_FLAG IS NOT NULL) AND
         (p_TERR_RSC_rec.FULL_ACCESS_FLAG <> FND_API.G_MISS_CHAR) ) THEN

        x_use_flag := 'Y';
        l_where_clause := l_where_clause || 'AND JTRV.FULL_ACCESS_FLAG = :p_TERR_RSC_14';

    END IF;

    x_where_clause := x_where_clause || l_where_clause;

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;


END  gen_where_clause;


PROCEDURE gen_bind (
    p_dsql_csr              IN      NUMBER,
    p_Terr_Rsc_Rec          IN      Terr_Rsc_Rec_Type
)
IS
    l_proc_name   VARCHAR2(30) := 'Gen_Bind: Terr_Rsc';

BEGIN

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

    IF ( (p_TERR_RSC_rec.TERR_RSC_ID IS NOT NULL) AND
         (p_TERR_RSC_rec.TERR_RSC_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_RSC_1', p_TERR_RSC_rec.TERR_RSC_ID);

    END IF;

    IF ( (p_TERR_RSC_rec.TERR_ID IS NOT NULL) AND
         (p_TERR_RSC_rec.TERR_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_RSC_7', p_TERR_RSC_rec.TERR_ID);

    END IF;

    IF ( (p_TERR_RSC_rec.RESOURCE_ID IS NOT NULL) AND
         (p_TERR_RSC_rec.RESOURCE_ID <> FND_API.G_MISS_NUM) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_RSC_8', p_TERR_RSC_rec.RESOURCE_ID);

    END IF;

    IF ( (p_TERR_RSC_rec.RESOURCE_TYPE IS NOT NULL) AND
         (p_TERR_RSC_rec.RESOURCE_TYPE <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_RSC_9', p_TERR_RSC_rec.RESOURCE_TYPE);

    END IF;

    IF ( (p_TERR_RSC_rec.ROLE IS NOT NULL) AND
         (p_TERR_RSC_rec.ROLE <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_RSC_10', p_TERR_RSC_rec.ROLE);

    END IF;

    IF ( (p_TERR_RSC_rec.PRIMARY_CONTACT_FLAG IS NOT NULL) AND
         (p_TERR_RSC_rec.PRIMARY_CONTACT_FLAG <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_RSC_11', p_TERR_RSC_rec.PRIMARY_CONTACT_FLAG);

    END IF;

    IF ( (p_TERR_RSC_rec.START_DATE_ACTIVE IS NOT NULL) AND
         (p_TERR_RSC_rec.START_DATE_ACTIVE <> FND_API.G_MISS_DATE) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_RSC_12', p_TERR_RSC_rec.START_DATE_ACTIVE);

    END IF;

    IF ( (p_TERR_RSC_rec.END_DATE_ACTIVE IS NOT NULL) AND
         (p_TERR_RSC_rec.END_DATE_ACTIVE <> FND_API.G_MISS_DATE) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_RSC_13', p_TERR_RSC_rec.END_DATE_ACTIVE);

    END IF;

    IF ( (p_TERR_RSC_rec.FULL_ACCESS_FLAG IS NOT NULL) AND
         (p_TERR_RSC_rec.FULL_ACCESS_FLAG <> FND_API.G_MISS_CHAR) ) THEN

        -- bind the input variables
        DBMS_SQL.BIND_VARIABLE(p_dsql_csr, ':p_TERR_RSC_14', p_TERR_RSC_rec.FULL_ACCESS_FLAG);

    END IF;

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

END  gen_bind;



-----------------------------------------------------------------------
--     ORDER BY CLAUSE
-----------------------------------------------------------------------
PROCEDURE gen_order_by_clause(
    x_return_status      OUT  NOCOPY VARCHAR2,
    x_msg_count          OUT  NOCOPY NUMBER,
    x_msg_data           OUT  NOCOPY VARCHAR2,
    p_order_by_rec       IN   order_by_rec_type,
    x_order_by_clause    OUT  NOCOPY VARCHAR2
)
IS

    l_proc_name   VARCHAR2(30) := 'Gen_Order_By_Clause';

    l_order_by_clause       VARCHAR2(1000) := FND_API.G_MISS_CHAR;

    l_util_order_by_tbl     JTF_CTM_UTILITY_PVT.Util_order_by_tbl_type;

BEGIN

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

      -- Hint: Developer should add more statements according to sort_rec_type
      -- Ex:
      -- l_util_order_by_tbl(1).col_choice := p_order_by_rec.customer_name;
      -- l_util_order_by_tbl(1).col_name := 'Customer_Name';

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'Invoke Translate_OrderBy');
        FND_MSG_PUB.Add;
    END IF;


    JTF_CTM_UTILITY_PVT.Translate_OrderBy (
            p_api_version        => 1.0,
            p_init_msg_list      => FND_API.G_FALSE,
            p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_order_by_tbl       => l_util_order_by_tbl,
            x_order_by_clause    => l_order_by_clause );

    IF (l_order_by_clause IS NOT NULL) THEN
        x_order_by_clause := 'ORDER BY ' || l_order_by_clause;
    ELSE
        x_order_by_clause := NULL;
    END IF;

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_proc_name);
        FND_MSG_PUB.Add;
    END IF;

END gen_order_by_clause;




--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Get_Territory_Header
--    Type      : PUBLIC
--    Function  : To get a list of territory headers
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--      p_terr_rec                 Terr_Rec_Type                    G_MISS_TERR_REC
--      p_terr_type_rec            Terr_Type_Rec_Type               G_MISS_TERR_TYPE_REC
--      p_terr_usg_rec             Terr_Usgs_Rec_Type               G_MISS_TERR_USGS_REC
--      p_terr_rsc_rec             Terr_Rsc_Rec_Type                G_MISS_TERR_RSC_REC
--      p_terr_qual_tbl            Terr_Qual_Tbl_Type               G_MISS_TERR_QUAL_TBL
--      p_terr_values_tbl          Terr_Values_Tbl_Type             G_MISS_TERR_VALUES_TBL
--      p_order_by_rec             order_by_rec_type                G_MISS_ORDER_BY_REC
--      p_return_all_rec           VARCHAR2                         FND_API.G_FALSE
--      p_num_rec_requested        NUMBER                           30
--      p_start_rec_num            NUMBER                           1
--
--     OUT     :
--      Parameter Name             Data Type
--      x_Return_Status            VARCHAR2(1)
--      x_Msg_Count                NUMBER
--      x_Msg_Data                 VARCHAR2(2000)
--      x_terr_header_tbl          Terr_Header_Tbl_Type
--      x_num_rec_returned         NUMBER
--      x_next_rec_num             NUMBER
--      x_total_num_rec            NUMBER
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Get_Territory_Header (
    p_Api_Version                IN   NUMBER,
    p_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_terr_rec                   IN   Terr_Rec_Type         := G_MISS_TERR_REC,
    p_terr_type_rec              IN   Terr_Type_Rec_Type    := G_MISS_TERR_TYPE_REC,
    p_terr_usg_rec               IN   Terr_Usgs_Rec_Type    := G_MISS_TERR_USGS_REC,
--    p_terr_qtype_usgs_tbl        IN   Terr_QType_Usgs_Tbl_Type    := G_MISS_TERR_QTYPE_USGS_TBL,
    p_terr_rsc_rec               IN   Terr_Rsc_Rec_Type     := G_MISS_TERR_RSC_REC,
    p_terr_qual_tbl              IN   Terr_Qual_Tbl_Type    := G_MISS_TERR_QUAL_TBL,
    p_terr_values_tbl            IN   Terr_Values_Tbl_Type  := G_MISS_TERR_VALUES_TBL,
    p_order_by_rec               IN   order_by_rec_type     := G_MISS_ORDER_BY_REC,
    p_return_all_rec             IN   VARCHAR2 := FND_API.G_FALSE,
    p_num_rec_requested          IN   NUMBER  := 30,
    p_start_rec_num              IN   NUMBER  := 1,
    x_terr_header_tbl            OUT  NOCOPY Terr_Header_Tbl_Type,
    x_num_rec_returned           OUT  NOCOPY NUMBER,
    x_next_rec_num               OUT  NOCOPY NUMBER,
    x_total_num_rec              OUT  NOCOPY NUMBER
)
IS

   l_api_name                CONSTANT VARCHAR2(30) := 'Get_Territory_Header';
   l_api_version             CONSTANT NUMBER   := 1.0;

   /* Local record counters */
   l_qtype_usgs_counter   NUMBER := 0;
   l_qual_counter         NUMBER := 0;
   l_val_counter          NUMBER := 0;
   l_num_rec_returned     NUMBER := 0; /* number of records returned by this call to API */
   l_next_rec_num         NUMBER := 1;

   /* TOTAL number of records returned by API */
   l_total_num_rec_returned     NUMBER := 0;

   /* Status local variable */
   l_return_status         VARCHAR2(1);

   /* Dynamic SQL statement elements */
   l_dsql_csr              NUMBER;
   l_dummy                 NUMBER;
   l_dsql_str              VARCHAR2(32767);
   l_select_clause         VARCHAR2(32767);
   l_from_clause           VARCHAR2(32767);
   l_where_clause          VARCHAR2(32767);
   l_order_by_clause       VARCHAR2(32767);

   /* Local scratch records */
   l_terr_header_rec        Terr_Header_Rec_Type;

   /* flag variables */
   l_use_terr_flag            VARCHAR2(1) := 'N';
   l_use_terr_type_flag       VARCHAR2(1) := 'N';
   l_use_terr_usg_flag        VARCHAR2(1) := 'N';
   l_use_terr_qtype_usg_flag  VARCHAR2(1) := 'N';
   l_use_terr_qual_flag       VARCHAR2(1) := 'N';
   l_use_terr_values_flag     VARCHAR2(1) := 'N';
   l_use_terr_rsc_flag        VARCHAR2(1) := 'N';


 BEGIN

    --dbms_output.put_line('at API BEGIN');


    /* Standard call to check for call compatibility */
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /* Initialize message list if p_init_msg_list is set to TRUE */
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
        FND_MSG_PUB.Add;
    END IF;

    /**********************************************************************************************
    ** API BODY START
    ***********************************************************************************************/

    /* Initialize API return status to SUCCESS */
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    --dbms_output.put_line('at API body start, l_return_status = '|| l_return_status);


    /* *************************************************
    ** Generate Dynamic SQL based on criteria passed in.
    ** Doing this for performance. Indexes are disabled
    ** when using NVL within static SQL statement.
    ** Ignore condition when criteria is NULL
    */

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'Open Cursor for Dynamic SQL');
        FND_MSG_PUB.Add;
    END IF;

    /******************************/
    /* OPEN CURSOR for processing */
    /******************************/
    l_dsql_csr := dbms_sql.open_cursor;

    --dbms_output.put_line('after open dsql cursor');


    /* Generate initial SQL statement: SELECT, FROM, and WHERE clauses
    ** Hint: Developer should modify gen_init_sql procedure.
    */
    gen_init_sql( l_select_clause, l_from_clause, l_where_clause );

    --dbms_output.put_line('[1] l_select_clause');
    --dbms_output.put_line('[1] l_from_clause');
    --dbms_output.put_line('[1] l_where_clause');

    --dbms_output.put_line('Dynamic creation of WHERE clause Start');

    /******************************************************/
    /* generate where clause using the following entities */
    /******************************************************/

    /* Hint: Developer should modify and implement
    ** the gen_where_clause procedure.
    ** This is an overloaded procedure.
    */

    /***********************/
    /* territory           */
    /***********************/
    gen_where_clause(l_dsql_csr, p_terr_rec, l_where_clause, l_use_terr_flag);
    --dbms_output.put_line('[2] l_where_clause = '|| l_where_clause);

    /* Hint: if master/detail relationship, generate Where clause for lines level criteria */

    /***********************/
    /* territory usages    */
    /***********************/
    gen_where_clause(l_dsql_csr, p_terr_usg_rec, l_where_clause, l_use_terr_usg_flag);
    --dbms_output.put_line('[3] l_where_clause = '|| l_where_clause);
    --dbms_output.put_line('[3] l_from_clause = '|| l_from_clause);

    /***********************/
    /* territory type      */
    /***********************/
    gen_where_clause(l_dsql_csr, p_terr_type_rec, l_where_clause, l_use_terr_type_flag);
    --dbms_output.put_line('[4] l_where_clause = '|| l_where_clause);
    --dbms_output.put_line('[4] l_from_clause = '|| l_from_clause);

    IF ( l_use_terr_type_flag = 'Y' ) THEN
        l_from_clause := 'JTF_TERR_TYPES JTTA, '  || l_from_clause;
        l_where_clause := l_where_clause ||
                          ' AND JTOV.TERRITORY_TYPE_ID = JTTA.TERR_TYPE_ID ';
    END IF;


    /*****************************************************************/
    /* territory qualifier type usages (transactions + resources)    */
    /*****************************************************************/

    --IF ( p_terr_qtype_usgs_tbl.COUNT <> 0 ) THEN
    --    FOR l_qtype_usgs_counter IN p_terr_qtype_usgs_tbl.FIRST .. p_terr_qual_tbl.LAST LOOP
    --
    --        /* for each record in table */
    --        gen_where_clause( l_dsql_csr, p_terr_qtype_usgs_tbl(l_qtype_usgs_counter), l_where_clause
    --                        , l_use_terr_qtype_usg_flag);
    --
    --    END LOOP;
    --END IF;
    --
    --IF ( l_use_terr_qtype_usg_flag = 'Y' ) THEN
    --    l_from_clause := 'JTF_TERR_TRANSACTIONS_V JTTV, '  || l_from_clause;
    --    l_where_clause := l_where_clause || ' AND JTTV.TERR_ID = JTOV.TERR_ID ';
    --END IF;

    --dbms_output.put_line('[5] l_where_clause = '|| l_where_clause);
    --dbms_output.put_line('[5] l_from_clause = '|| l_from_clause);

    /***************************/
    /* territory qualifiers    */
    /***************************/

    IF ( p_terr_qual_tbl.COUNT > 0 ) THEN
        FOR l_qual_counter IN p_terr_qual_tbl.FIRST .. p_terr_qual_tbl.LAST LOOP

            --dbms_output.put_line('[6] l_where_clause = '|| l_where_clause);

            /* for each record in table */
            gen_where_clause(l_dsql_csr, p_terr_qual_tbl(l_qual_counter), l_where_clause, l_use_terr_qual_flag);

        END LOOP;
    END IF;

    IF ( l_use_terr_qual_flag = 'Y' ) THEN
        l_from_clause := 'JTF_TERR_QUALIFIERS_V JTQV, ' || l_from_clause;
        l_where_clause := l_where_clause || ' AND JTQV.TERR_ID = JTOV.TERR_ID ';
    END IF;


    --dbms_output.put_line('[6] l_from_clause = '|| l_from_clause);

    /***************************/
    /* territory values        */
    /***************************/

    IF ( p_terr_values_tbl.COUNT > 0 ) THEN
        FOR l_val_counter IN p_terr_values_tbl.FIRST .. p_terr_values_tbl.LAST LOOP

            /* for each record in table */
            gen_where_clause( l_dsql_csr, p_terr_values_tbl(l_val_counter),
                              l_where_clause, l_use_terr_values_flag);

         END LOOP;
    END IF;

    IF ( l_use_terr_values_flag = 'Y' ) THEN

        /* join jtf_terr_qualifiers with jtf_terr
        ** and then jtf_terr_values with jtf_terr_qualifiers
        */
        IF ( l_use_terr_qual_flag <> 'Y' ) THEN
            l_from_clause := 'JTF_TERR_QUALIFIERS_V JTQV, ' || l_from_clause;
            l_where_clause := l_where_clause || ' AND JTQV.TERR_ID = JTOV.TERR_ID ';
        END IF;

        l_from_clause := 'JTF_TERR_VALUES JTV, '  || l_from_clause;
        l_where_clause := l_where_clause || ' AND JTV.TERR_QUAL_ID = JTQV.TERR_QUAL_ID ';
    END IF;

    --dbms_output.put_line('[7] l_where_clause = '|| l_where_clause);
    --dbms_output.put_line('[7] l_from_clause = '|| l_from_clause);

    /***************************/
    /* territory resources     */
    /***************************/

    gen_where_clause(l_dsql_csr, p_terr_rsc_rec, l_where_clause, l_use_terr_rsc_flag);

    IF ( l_use_terr_rsc_flag = 'Y' ) THEN
        l_from_clause := 'JTF_TERR_RESOURCES_V JTRV, ' || l_from_clause;
        l_where_clause := l_where_clause || ' AND JTRV.TERR_ID = JTOV.TERR_ID ';
    END IF;


    /* the FROM clause has been built right to left
    ** to make the SQL statement more efficient
    */
    l_from_clause := ' FROM ' || l_from_clause;

    --dbms_output.put_line('[8] l_select_clause = '|| l_select_clause);
    --dbms_output.put_line('[8] l_from_clause = '|| l_from_clause);
    --dbms_output.put_line('[8] l_where_clause = '|| l_where_clause);

    /* Generate order by clause */
    gen_order_by_clause ( l_return_status,
                          x_msg_count,
                          x_msg_data,
                          p_order_by_rec,
                          l_order_by_clause );

    /* build string that will be used by dynamic SQL */
    l_dsql_str  := l_select_clause || l_from_clause || l_where_clause || l_order_by_clause;


    --dbms_output.put_line('[9] about to parse query');
    /************************/
    /* parse the query      */
    /************************/
    DBMS_SQL.PARSE(l_dsql_csr, l_dsql_str, DBMS_SQL.V7);

    /************************/
    /* bind input variables */
    /************************/

    IF (l_use_terr_flag = 'Y') THEN
        --dbms_output.put_line('[10] binding terr_rec variables');
        /* this is an overloaded procedure */
        gen_bind(l_dsql_csr, p_terr_rec);
    END IF;

    /* Hint: if master/detail relationship, generate binds for lines level criteria */

    IF (l_use_terr_usg_flag = 'Y') THEN
        --dbms_output.put_line('[11] binding terr_usg_rec variables');
        gen_bind(l_dsql_csr, p_terr_usg_rec);
    END IF;

    IF (l_use_terr_type_flag = 'Y') THEN
        --dbms_output.put_line('[12] binding terr_type_rec variables');
        gen_bind(l_dsql_csr, p_terr_type_rec);
    END IF;

    --IF (l_use_terr_qtype_usg_flag = 'Y') THEN
    --  FOR l_qtype_usgs_counter IN p_terr_qtype_usgs_tbl.FIRST .. p_terr_qtype_usgs_tbl.LAST LOOP
    --      /* for each record in table */
    --      gen_bind(l_dsql_csr, p_terr_qtype_usgs_tbl(l_qtype_usgs_counter));
    --  END LOOP;
    --END IF;

    IF (l_use_terr_qual_flag = 'Y') THEN
      --dbms_output.put_line('[14] binding terr_qual_rec variables');
      FOR l_qual_counter IN 1 .. p_terr_qual_tbl.COUNT LOOP
          /* for each record in table */
          gen_bind(l_dsql_csr, p_terr_qual_tbl(l_qual_counter));
      END LOOP;
    END IF;

    IF (l_use_terr_values_flag = 'Y') THEN
      --dbms_output.put_line('[15] binding terr_value_rec variables');
      FOR l_val_counter IN p_terr_values_tbl.FIRST .. p_terr_values_tbl.LAST LOOP
          /* for each record in table */
          gen_bind(l_dsql_csr, p_terr_values_tbl(l_val_counter));
      END LOOP;
    END IF;

    IF (l_use_terr_rsc_flag = 'Y') THEN
        --dbms_output.put_line('[16] binding terr_rsc_rec variables');
        gen_bind(l_dsql_csr, p_terr_rsc_rec);
    END IF;

    --dbms_output.put_line('[17] defining SQL columns');
    /* define columns */
    define_dsql_columns ( l_dsql_csr, l_terr_header_rec );

    --dbms_output.put_line('[18] executing query');
    /* execute query */
    l_dummy := DBMS_SQL.EXECUTE ( l_dsql_csr );

    /* Fetch rows into buffer, and then put in PL/SQL table */
    LOOP

        /* exit at last row in cursor */
        IF (DBMS_SQL.FETCH_ROWS (l_dsql_csr) = 0 ) THEN
            EXIT;
        END IF;

        /* all records are to be returned OR number of records requested is null
        ** OR number of records returned less than number of records requested
        */
        IF ( p_return_all_rec = FND_API.G_TRUE OR
             p_num_rec_requested = FND_API.G_MISS_NUM OR
             l_num_rec_returned < p_num_rec_requested ) THEN

             /* retrieve values into columns */
             get_dsql_column_values ( l_dsql_csr, l_terr_header_rec);

             /* increment total number of records returned counter */
             l_total_num_rec_returned := l_total_num_rec_returned + 1;

             --dbms_output.put_line('fetching row ' || TO_CHAR(l_total_num_rec_returned));

             /* TOTAL number of records returned is >= record to start returning from
             ** AND number of records returned is < number of records requested
             */
             IF ( l_total_num_rec_returned >= p_start_rec_num ) THEN

                  l_num_rec_returned := l_num_rec_returned + 1;

                  --dbms_output.put_line('returning row ' || TO_CHAR(l_num_rec_returned));

                  x_terr_header_tbl ( l_num_rec_returned ) := l_terr_header_rec;

                  --dbms_output.put_line( 'fetched header ' ||
                  --                     x_terr_header_tbl(l_num_rec_returned).terr_name);

             END IF;

             l_next_rec_num := l_total_num_rec_returned + 1;

        END IF;

    END LOOP;

    /* close cursor */
    DBMS_SQL.CLOSE_CURSOR(l_dsql_csr);

    /* save return variables */
    x_num_rec_returned := l_num_rec_returned;
    x_next_rec_num := l_next_rec_num;
    x_total_num_rec := l_total_num_rec_returned;

    /* save return status */
    x_return_status := l_return_status;

    /**********************************************************************************************
    ** API BODY END
    ***********************************************************************************************/

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
        FND_MSG_PUB.Add;
    END IF;

    /* Standard call to get message count and if count is 1, get message info. */
    FND_MSG_PUB.Count_And_Get
    (   p_count          =>   x_msg_count,
        p_data           =>   x_msg_data
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        --dbms_output.put_line( 'FND_API.G_EXC_ERROR: return_status = '|| l_return_status );

        FND_MSG_PUB.Count_And_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
        );


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         --dbms_output.put_line( 'FND_API.G_EXC_UNEXPECTED_ERROR: return_status = '|| l_return_status );

        FND_MSG_PUB.Count_And_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
        );

    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         --dbms_output.put_line( 'OTHERS: return_status = '|| l_return_status );

         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;

         FND_MSG_PUB.Count_And_Get
         ( p_count         =>      x_msg_count,
           p_data          =>      x_msg_data
         );

End Get_Territory_Header;


--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Get_Territory_Details
--    Type      : PUBLIC
--    Function  : To get a territory's details
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      p_terr_id                  NUMBER                           FND_API.G_MISS_NUM
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name             Data Type
--      x_Return_Status            VARCHAR2(1)
--      x_Msg_Count                NUMBER
--      x_Msg_Data                 VARCHAR2(2000)
--      x_terr_rec                 Terr_Rec_Type
--      x_terr_type_rec            Terr_Type_Rec_Type
--      x_terr_sub_terr_tbl        Terr_Tbl_Type
--      x_terr_usgs_tbl            Terr_Usgs_Tbl_Type
--      x_terr_qtype_usgs_tbl      Terr_QType_Usgs_Tbl_Type
--      x_terr_qual_tbl            Terr_Qual_Tbl_Type
--      x_terr_values_tbl          Terr_Values_Tbl_Type
--      x_terr_rsc_tbl             Terr_Rsc_Tbl_Type
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Get_Territory_Details (
    p_Api_Version                IN   NUMBER,
    p_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_terr_id                    IN   NUMBER     := FND_API.G_MISS_NUM,
    x_terr_rec                   OUT  NOCOPY Terr_Rec_Type,
    x_terr_type_rec              OUT  NOCOPY Terr_Type_Rec_Type,
    x_terr_sub_terr_tbl          OUT  NOCOPY Terr_Tbl_Type,
    x_terr_usgs_tbl              OUT  NOCOPY Terr_Usgs_Tbl_Type,
    x_terr_qtype_usgs_tbl        OUT  NOCOPY Terr_QType_Usgs_Tbl_Type,
    x_terr_qual_tbl              OUT  NOCOPY Terr_Qual_Tbl_Type,
    x_terr_values_tbl            OUT  NOCOPY Terr_Values_Tbl_Type,
    x_terr_rsc_tbl               OUT  NOCOPY Terr_Rsc_Tbl_Type
)
IS

   l_api_name                CONSTANT VARCHAR2(30) := 'Get_Territory_Details';
   l_api_version             CONSTANT NUMBER   := 1.0;

   /**********************/
   /* cursor definitions */
   /**********************/

   /* return territory record */
   CURSOR get_terr ( p_terr_id NUMBER) IS
   SELECT
      jtov.TERR_ID
    , jtov.LAST_UPDATE_DATE
    , jtov.LAST_UPDATED_BY
    , jtov.CREATION_DATE
    , jtov.CREATED_BY
    , jtov.LAST_UPDATE_LOGIN
    , jtov.REQUEST_ID
    , jtov.PROGRAM_APPLICATION_ID
    , jtov.PROGRAM_ID
    , jtov.PROGRAM_UPDATE_DATE
    , jtov.APPLICATION_SHORT_NAME
    , jtov.NAME
    , jtov.ENABLED_FLAG
    , jtov.START_DATE_ACTIVE
    , jtov.END_DATE_ACTIVE
    , jtov.PLANNED_FLAG
    , jtov.PARENT_TERRITORY_ID
    , jtov.TERRITORY_TYPE_ID
    , jtov.TEMPLATE_TERRITORY_ID
    , jtov.TEMPLATE_FLAG
    , jtov.ESCALATION_TERRITORY_ID
    , jtov.ESCALATION_TERRITORY_FLAG
    , jtov.OVERLAP_ALLOWED_FLAG
    , jtov.RANK
    , jtov.DESCRIPTION
    , jtov.UPDATE_FLAG
    , jtov.AUTO_ASSIGN_RESOURCES_FLAG
    , jtov.ATTRIBUTE_CATEGORY
    , jtov.ATTRIBUTE1
    , jtov.ATTRIBUTE2
    , jtov.ATTRIBUTE3
    , jtov.ATTRIBUTE4
    , jtov.ATTRIBUTE5
    , jtov.ATTRIBUTE6
    , jtov.ATTRIBUTE7
    , jtov.ATTRIBUTE8
    , jtov.ATTRIBUTE9
    , jtov.ATTRIBUTE10
    , jtov.ATTRIBUTE11
    , jtov.ATTRIBUTE12
    , jtov.ATTRIBUTE13
    , jtov.ATTRIBUTE14
    , jtov.ATTRIBUTE15
    , jtov.ORG_ID
    , jtov.TERR_TYPE_NAME
    , jtov.PARENT_TERR_NAME
    , jtov.ESCALATION_TERR_NAME
    , jtov.TEMPLATE_TERR_NAME
    , jtov.TERR_USG_ID
    , jtov.SOURCE_ID
    , jtov.TERR_USAGE
   FROM JTF_TERR_OVERVIEW_V jtov
   WHERE jtov.TERR_ID = p_terr_id;

   /* return territory type */
   CURSOR get_terr_type ( p_terr_type_id NUMBER ) IS
   SELECT
      jtta.TERR_TYPE_ID
    , jtta.LAST_UPDATED_BY
    , jtta.LAST_UPDATE_DATE
    , jtta.CREATED_BY
    , jtta.CREATION_DATE
    , jtta.LAST_UPDATE_LOGIN
    , jtta.APPLICATION_SHORT_NAME
    , jtta.NAME
    , jtta.ENABLED_FLAG
    , jtta.DESCRIPTION
    , jtta.START_DATE_ACTIVE
    , jtta.END_DATE_ACTIVE
    , jtta.ATTRIBUTE_CATEGORY
    , jtta.ATTRIBUTE1
    , jtta.ATTRIBUTE2
    , jtta.ATTRIBUTE3
    , jtta.ATTRIBUTE4
    , jtta.ATTRIBUTE5
    , jtta.ATTRIBUTE6
    , jtta.ATTRIBUTE7
    , jtta.ATTRIBUTE8
    , jtta.ATTRIBUTE9
    , jtta.ATTRIBUTE10
    , jtta.ATTRIBUTE11
    , jtta.ATTRIBUTE12
    , jtta.ATTRIBUTE13
    , jtta.ATTRIBUTE14
    , jtta.ATTRIBUTE15
    , jtta.ORG_ID
   FROM JTF_TERR_TYPES jtta
   WHERE terr_type_id = p_terr_type_id;

   /* return territory's (child) sub-territories */
   CURSOR get_sub_terr ( p_terr_id NUMBER) IS
   SELECT
      jtov.TERR_ID
    , jtov.LAST_UPDATE_DATE
    , jtov.LAST_UPDATED_BY
    , jtov.CREATION_DATE
    , jtov.CREATED_BY
    , jtov.LAST_UPDATE_LOGIN
    , jtov.REQUEST_ID
    , jtov.PROGRAM_APPLICATION_ID
    , jtov.PROGRAM_ID
    , jtov.PROGRAM_UPDATE_DATE
    , jtov.APPLICATION_SHORT_NAME
    , jtov.NAME
    , jtov.ENABLED_FLAG
    , jtov.START_DATE_ACTIVE
    , jtov.END_DATE_ACTIVE
    , jtov.PLANNED_FLAG
    , jtov.PARENT_TERRITORY_ID
    , jtov.TERRITORY_TYPE_ID
    , jtov.TEMPLATE_TERRITORY_ID
    , jtov.TEMPLATE_FLAG
    , jtov.ESCALATION_TERRITORY_ID
    , jtov.ESCALATION_TERRITORY_FLAG
    , jtov.OVERLAP_ALLOWED_FLAG
    , jtov.RANK
    , jtov.DESCRIPTION
    , jtov.UPDATE_FLAG
    , jtov.AUTO_ASSIGN_RESOURCES_FLAG
    , jtov.ATTRIBUTE_CATEGORY
    , jtov.ATTRIBUTE1
    , jtov.ATTRIBUTE2
    , jtov.ATTRIBUTE3
    , jtov.ATTRIBUTE4
    , jtov.ATTRIBUTE5
    , jtov.ATTRIBUTE6
    , jtov.ATTRIBUTE7
    , jtov.ATTRIBUTE8
    , jtov.ATTRIBUTE9
    , jtov.ATTRIBUTE10
    , jtov.ATTRIBUTE11
    , jtov.ATTRIBUTE12
    , jtov.ATTRIBUTE13
    , jtov.ATTRIBUTE14
    , jtov.ATTRIBUTE15
    , jtov.ORG_ID
    , jtov.TERR_TYPE_NAME
    , jtov.PARENT_TERR_NAME
    , jtov.ESCALATION_TERR_NAME
    , jtov.TEMPLATE_TERR_NAME
    , jtov.TERR_USG_ID
    , jtov.SOURCE_ID
    , jtov.TERR_USAGE
   FROM JTF_TERR_OVERVIEW_V jtov
   WHERE jtov.parent_territory_id = p_terr_id;

    /* return territory usages */
    CURSOR get_terr_usgs ( p_terr_id NUMBER) IS
    SELECT
      jtua.TERR_USG_ID
    , jtua.LAST_UPDATE_DATE
    , jtua.LAST_UPDATED_BY
    , jtua.CREATION_DATE
    , jtua.CREATED_BY
    , jtua.LAST_UPDATE_LOGIN
    , jtua.TERR_ID
    , jtua.SOURCE_ID
    , jtua.ORG_ID
    , jse.MEANING USAGE
    FROM JTF_TERR_USGS jtua, JTF_SOURCES jse
    WHERE jtua.terr_id = p_terr_id
    AND jtua.SOURCE_ID = jse.SOURCE_ID;

    /* return territory qualifier type usages and descriptions */
    CURSOR get_terr_qtype_usgs ( p_terr_id NUMBER) IS
    SELECT
      jttv.TERR_QTYPE_USG_ID
    , jttv.LAST_UPDATED_BY
    , jttv.LAST_UPDATE_DATE
    , jttv.CREATED_BY
    , jttv.CREATION_DATE
    , jttv.LAST_UPDATE_LOGIN
    , jttv.TERR_ID
    , jttv.QUAL_TYPE_USG_ID
    , jttv.ORG_ID
    , jttv.SOURCE_ID
    , jttv.QUAL_TYPE_ID
    , jttv.QUALIFIER_TYPE_NAME
    , jttv.QUALIFIER_TYPE_DESCRIPTION
    FROM  JTF_TERR_TRANSACTIONS_V jttv
    WHERE jttv.terr_id = p_terr_id;


    /* return territory qualifiers and descriptions */
    CURSOR get_terr_qual ( p_terr_id NUMBER) IS
    SELECT
      jtqv.TERR_QUAL_ID
    , jtqv.LAST_UPDATE_DATE
    , jtqv.LAST_UPDATED_BY
    , jtqv.CREATION_DATE
    , jtqv.CREATED_BY
    , jtqv.LAST_UPDATE_LOGIN
    , jtqv.TERR_ID
    , jtqv.QUAL_USG_ID
    , jtqv.USE_TO_NAME_FLAG
    , jtqv.GENERATE_FLAG
    , jtqv.OVERLAP_ALLOWED_FLAG
    , jtqv.QUALIFIER_MODE
    , jtqv.ORG_ID
    , jtqv.DISPLAY_TYPE
    , jtqv.LOV_SQL
    , jtqv.CONVERT_TO_ID_FLAG
    , jtqv.QUAL_TYPE_ID
    , jtqv.QUALIFIER_TYPE_NAME
    , jtqv.QUALIFIER_TYPE_DESCRIPTION
    , jtqv.QUALIFIER_NAME
    FROM JTF_TERR_QUALIFIERS_V jtqv
    WHERE jtqv.terr_id = p_terr_id;

    /* return territory qualifier values */
    CURSOR get_terr_values ( p_terr_id NUMBER) IS
    SELECT
      j1.TERR_VALUE_ID
    , j1.LAST_UPDATED_BY
    , j1.LAST_UPDATE_DATE
    , j1.CREATED_BY
    , j1.CREATION_DATE
    , j1.LAST_UPDATE_LOGIN
    , j1.TERR_QUAL_ID
    , j1.INCLUDE_FLAG
    , j1.COMPARISON_OPERATOR
    , j3.CONVERT_TO_ID_FLAG ID_USED_FLAG -- modified for bug # 4691184
    , j1.LOW_VALUE_CHAR_ID
    , j1.LOW_VALUE_CHAR
    , j1.HIGH_VALUE_CHAR
    , j1.LOW_VALUE_NUMBER
    , j1.HIGH_VALUE_NUMBER
    , j1.VALUE_SET
    , j1.INTEREST_TYPE_ID
    , j1.PRIMARY_INTEREST_CODE_ID
    , j1.SECONDARY_INTEREST_CODE_ID
    , j1.CURRENCY_CODE
    , j1.ORG_ID
    FROM JTF_TERR_VALUES j1, JTF_TERR_QUAL j2, JTF_QUAL_USGS j3
    WHERE j1.terr_qual_id = j2.terr_qual_id
    AND j2.terr_id = p_terr_id
    AND j3.qual_usg_id = j2.qual_usg_id;


    /* return territory resources */
    CURSOR get_terr_rsc ( p_terr_id NUMBER) IS
    SELECT
      JTRV.TERR_RSC_ID
    , JTRV.LAST_UPDATE_DATE
    , JTRV.LAST_UPDATED_BY
    , JTRV.CREATION_DATE
    , JTRV.CREATED_BY
    , JTRV.LAST_UPDATE_LOGIN
    , JTRV.TERR_ID
    , JTRV.RESOURCE_ID
    , JTRV.RESOURCE_TYPE
    , JTRV.ROLE
    , JTRV.PRIMARY_CONTACT_FLAG
    , JTRV.START_DATE_ACTIVE
    , JTRV.END_DATE_ACTIVE
    , JTRV.FULL_ACCESS_FLAG
    , JTRV.ORG_ID
    , JTRV.RESOURCE_NAME
    FROM JTF_TERR_RESOURCES_V JTRV
    WHERE terr_id = p_terr_id;


   /* Status local variable */
   l_return_status         VARCHAR2(1);

   /* Local scratch records */
   l_terr_rec               Terr_Rec_Type;
   l_terr_type_rec          Terr_Type_Rec_Type;
   l_terr_sub_terr_tbl      Terr_Tbl_Type;
   l_terr_usgs_tbl          Terr_Usgs_Tbl_Type;
   l_terr_qtype_usgs_tbl    Terr_QType_Usgs_Tbl_Type;
   l_terr_qual_tbl          Terr_Qual_Tbl_Type;
   l_terr_values_tbl        Terr_Values_Tbl_Type;
   l_terr_rsc_tbl           Terr_Rsc_Tbl_Type;

   /* table counter */
   counter  NUMBER := 0;

BEGIN

    /* Standard call to check for call compatibility */
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /* Initialize message list if p_init_msg_list is set to TRUE */
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
        FND_MSG_PUB.Add;
    END IF;


    /**********************************************************************************************
    ** API BODY START
    ***********************************************************************************************/


    /* Initialize API return status to SUCCESS */
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    /****************************/
    /* get the territory record */
    /****************************/
    OPEN get_terr ( p_terr_id );
    FETCH get_terr INTO
      l_terr_rec.TERR_ID
    , l_terr_rec.LAST_UPDATE_DATE
    , l_terr_rec.LAST_UPDATED_BY
    , l_terr_rec.CREATION_DATE
    , l_terr_rec.CREATED_BY
    , l_terr_rec.LAST_UPDATE_LOGIN
    , l_terr_rec.REQUEST_ID
    , l_terr_rec.PROGRAM_APPLICATION_ID
    , l_terr_rec.PROGRAM_ID
    , l_terr_rec.PROGRAM_UPDATE_DATE
    , l_terr_rec.APPLICATION_SHORT_NAME
    , l_terr_rec.NAME
    , l_terr_rec.ENABLED_FLAG
    , l_terr_rec.START_DATE_ACTIVE
    , l_terr_rec.END_DATE_ACTIVE
    , l_terr_rec.PLANNED_FLAG
    , l_terr_rec.PARENT_TERRITORY_ID
    , l_terr_rec.TERRITORY_TYPE_ID
    , l_terr_rec.TEMPLATE_TERRITORY_ID
    , l_terr_rec.TEMPLATE_FLAG
    , l_terr_rec.ESCALATION_TERRITORY_ID
    , l_terr_rec.ESCALATION_TERRITORY_FLAG
    , l_terr_rec.OVERLAP_ALLOWED_FLAG
    , l_terr_rec.RANK
    , l_terr_rec.DESCRIPTION
    , l_terr_rec.UPDATE_FLAG
    , l_terr_rec.AUTO_ASSIGN_RESOURCES_FLAG
    , l_terr_rec.ATTRIBUTE_CATEGORY
    , l_terr_rec.ATTRIBUTE1
    , l_terr_rec.ATTRIBUTE2
    , l_terr_rec.ATTRIBUTE3
    , l_terr_rec.ATTRIBUTE4
    , l_terr_rec.ATTRIBUTE5
    , l_terr_rec.ATTRIBUTE6
    , l_terr_rec.ATTRIBUTE7
    , l_terr_rec.ATTRIBUTE8
    , l_terr_rec.ATTRIBUTE9
    , l_terr_rec.ATTRIBUTE10
    , l_terr_rec.ATTRIBUTE11
    , l_terr_rec.ATTRIBUTE12
    , l_terr_rec.ATTRIBUTE13
    , l_terr_rec.ATTRIBUTE14
    , l_terr_rec.ATTRIBUTE15
    , l_terr_rec.ORG_ID
    , l_terr_rec.TERR_TYPE_NAME
    , l_terr_rec.PARENT_TERR_NAME
    , l_terr_rec.ESCALATION_TERR_NAME
    , l_terr_rec.TEMPLATE_TERR_NAME
    , l_terr_rec.TERR_USG_ID
    , l_terr_rec.SOURCE_ID
    , l_terr_rec.TERR_USAGE;

    IF get_terr%NOTFOUND THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        /* Debug message */
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            FND_MESSAGE.Set_Name ('JTF',  G_PKG_NAME || ': Territory record not found');
            FND_MSG_PUB.ADD;
        END IF;
    END IF;

    CLOSE get_terr;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --dbms_output.put_line( 'get_terr: return_status = '|| l_return_status ||
    --                      ' terr_name = ' || l_terr_rec.name);

    /*************************************************************************/
    /* if this territory has a territory type, get the territory type record */
    /*************************************************************************/
    IF (l_terr_rec.territory_type_id IS NOT NULL) THEN

        OPEN get_terr_type ( l_terr_rec.territory_type_id );
        FETCH get_terr_type INTO
          l_terr_type_rec.TERR_TYPE_ID
        , l_terr_type_rec.LAST_UPDATED_BY
        , l_terr_type_rec.LAST_UPDATE_DATE
        , l_terr_type_rec.CREATED_BY
        , l_terr_type_rec.CREATION_DATE
        , l_terr_type_rec.LAST_UPDATE_LOGIN
        , l_terr_type_rec.APPLICATION_SHORT_NAME
        , l_terr_type_rec.NAME
        , l_terr_type_rec.ENABLED_FLAG
        , l_terr_type_rec.DESCRIPTION
        , l_terr_type_rec.START_DATE_ACTIVE
        , l_terr_type_rec.END_DATE_ACTIVE
        , l_terr_type_rec.ATTRIBUTE_CATEGORY
        , l_terr_type_rec.ATTRIBUTE1
        , l_terr_type_rec.ATTRIBUTE2
        , l_terr_type_rec.ATTRIBUTE3
        , l_terr_type_rec.ATTRIBUTE4
        , l_terr_type_rec.ATTRIBUTE5
        , l_terr_type_rec.ATTRIBUTE6
        , l_terr_type_rec.ATTRIBUTE7
        , l_terr_type_rec.ATTRIBUTE8
        , l_terr_type_rec.ATTRIBUTE9
        , l_terr_type_rec.ATTRIBUTE10
        , l_terr_type_rec.ATTRIBUTE11
        , l_terr_type_rec.ATTRIBUTE12
        , l_terr_type_rec.ATTRIBUTE13
        , l_terr_type_rec.ATTRIBUTE14
        , l_terr_type_rec.ATTRIBUTE15
        , l_terr_type_rec.ORG_ID;

        IF get_terr_type%NOTFOUND THEN

            /* Debug message */
            IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
                FND_MESSAGE.Set_Name ('JTF',  G_PKG_NAME || ': Terr Type record not found');
                FND_MSG_PUB.ADD;
            END IF;
        END IF;

        CLOSE get_terr_type;
    END IF;

    --dbms_output.put_line( 'get_terr_type: return_status = '|| l_return_status ||
    --                      ' terr_type_name = ' || l_terr_type_rec.name);

    /***********************/
    /* get sub territories */
    /***********************/
    counter := 0;

    OPEN get_sub_terr ( p_terr_id );
    LOOP
        FETCH get_sub_terr INTO
          l_terr_sub_terr_tbl(counter).TERR_ID
        , l_terr_sub_terr_tbl(counter).LAST_UPDATE_DATE
        , l_terr_sub_terr_tbl(counter).LAST_UPDATED_BY
        , l_terr_sub_terr_tbl(counter).CREATION_DATE
        , l_terr_sub_terr_tbl(counter).CREATED_BY
        , l_terr_sub_terr_tbl(counter).LAST_UPDATE_LOGIN
        , l_terr_sub_terr_tbl(counter).REQUEST_ID
        , l_terr_sub_terr_tbl(counter).PROGRAM_APPLICATION_ID
        , l_terr_sub_terr_tbl(counter).PROGRAM_ID
        , l_terr_sub_terr_tbl(counter).PROGRAM_UPDATE_DATE
        , l_terr_sub_terr_tbl(counter).APPLICATION_SHORT_NAME
        , l_terr_sub_terr_tbl(counter).NAME
        , l_terr_sub_terr_tbl(counter).ENABLED_FLAG
        , l_terr_sub_terr_tbl(counter).START_DATE_ACTIVE
        , l_terr_sub_terr_tbl(counter).END_DATE_ACTIVE
        , l_terr_sub_terr_tbl(counter).PLANNED_FLAG
        , l_terr_sub_terr_tbl(counter).PARENT_TERRITORY_ID
        , l_terr_sub_terr_tbl(counter).TERRITORY_TYPE_ID
        , l_terr_sub_terr_tbl(counter).TEMPLATE_TERRITORY_ID
        , l_terr_sub_terr_tbl(counter).TEMPLATE_FLAG
        , l_terr_sub_terr_tbl(counter).ESCALATION_TERRITORY_ID
        , l_terr_sub_terr_tbl(counter).ESCALATION_TERRITORY_FLAG
        , l_terr_sub_terr_tbl(counter).OVERLAP_ALLOWED_FLAG
        , l_terr_sub_terr_tbl(counter).RANK
        , l_terr_sub_terr_tbl(counter).DESCRIPTION
        , l_terr_sub_terr_tbl(counter).UPDATE_FLAG
        , l_terr_sub_terr_tbl(counter).AUTO_ASSIGN_RESOURCES_FLAG
        , l_terr_sub_terr_tbl(counter).ATTRIBUTE_CATEGORY
        , l_terr_sub_terr_tbl(counter).ATTRIBUTE1
        , l_terr_sub_terr_tbl(counter).ATTRIBUTE2
        , l_terr_sub_terr_tbl(counter).ATTRIBUTE3
        , l_terr_sub_terr_tbl(counter).ATTRIBUTE4
        , l_terr_sub_terr_tbl(counter).ATTRIBUTE5
        , l_terr_sub_terr_tbl(counter).ATTRIBUTE6
        , l_terr_sub_terr_tbl(counter).ATTRIBUTE7
        , l_terr_sub_terr_tbl(counter).ATTRIBUTE8
        , l_terr_sub_terr_tbl(counter).ATTRIBUTE9
        , l_terr_sub_terr_tbl(counter).ATTRIBUTE10
        , l_terr_sub_terr_tbl(counter).ATTRIBUTE11
        , l_terr_sub_terr_tbl(counter).ATTRIBUTE12
        , l_terr_sub_terr_tbl(counter).ATTRIBUTE13
        , l_terr_sub_terr_tbl(counter).ATTRIBUTE14
        , l_terr_sub_terr_tbl(counter).ATTRIBUTE15
        , l_terr_sub_terr_tbl(counter).ORG_ID
        , l_terr_sub_terr_tbl(counter).TERR_TYPE_NAME
        , l_terr_sub_terr_tbl(counter).PARENT_TERR_NAME
        , l_terr_sub_terr_tbl(counter).ESCALATION_TERR_NAME
        , l_terr_sub_terr_tbl(counter).TEMPLATE_TERR_NAME
        , l_terr_sub_terr_tbl(counter).TERR_USG_ID
        , l_terr_sub_terr_tbl(counter).SOURCE_ID
        , l_terr_sub_terr_tbl(counter).TERR_USAGE;

        EXIT WHEN get_sub_terr%NOTFOUND;

        --dbms_output.put_line( 'get_sub_terr: counter = '|| counter ||
        --                      ' terr_name = ' || l_terr_sub_terr_tbl(counter).name);

        counter := counter + 1;

    END LOOP;
    CLOSE get_sub_terr;

    --dbms_output.put_line( 'AFTER get_sub_terr: counter = '|| counter );

    /************************/
    /* get territory usages */
    /************************/
    counter := 0;

    OPEN get_terr_usgs ( p_terr_id );
    LOOP
        FETCH get_terr_usgs INTO
          l_terr_usgs_tbl(counter).TERR_USG_ID
        , l_terr_usgs_tbl(counter).LAST_UPDATE_DATE
        , l_terr_usgs_tbl(counter).LAST_UPDATED_BY
        , l_terr_usgs_tbl(counter).CREATION_DATE
        , l_terr_usgs_tbl(counter).CREATED_BY
        , l_terr_usgs_tbl(counter).LAST_UPDATE_LOGIN
        , l_terr_usgs_tbl(counter).TERR_ID
        , l_terr_usgs_tbl(counter).SOURCE_ID
        , l_terr_usgs_tbl(counter).ORG_ID
        , l_terr_usgs_tbl(counter).USAGE;

        EXIT WHEN get_terr_usgs%NOTFOUND;

        --dbms_output.put_line( 'get_terr_usgs: counter = '|| counter ||
        --                     ' terr_usage = ' || l_terr_usgs_tbl(counter).source_id ||
        --                     ' usage = ' || l_terr_usgs_tbl(counter).usage);

        counter := counter + 1;

    END LOOP;
    CLOSE get_terr_usgs;

   --dbms_output.put_line( 'AFTER get_terr_usgs: counter = '|| counter );

    /***************************************/
    /* get territory qualifier type usages */
    /***************************************/
    counter := 0;

    OPEN get_terr_qtype_usgs ( p_terr_id );
    LOOP
        FETCH get_terr_qtype_usgs INTO
          l_terr_qtype_usgs_tbl(counter).TERR_QTYPE_USG_ID
        , l_terr_qtype_usgs_tbl(counter).LAST_UPDATED_BY
        , l_terr_qtype_usgs_tbl(counter).LAST_UPDATE_DATE
        , l_terr_qtype_usgs_tbl(counter).CREATED_BY
        , l_terr_qtype_usgs_tbl(counter).CREATION_DATE
        , l_terr_qtype_usgs_tbl(counter).LAST_UPDATE_LOGIN
        , l_terr_qtype_usgs_tbl(counter).TERR_ID
        , l_terr_qtype_usgs_tbl(counter).QUAL_TYPE_USG_ID
        , l_terr_qtype_usgs_tbl(counter).ORG_ID
        , l_terr_qtype_usgs_tbl(counter).SOURCE_ID
        , l_terr_qtype_usgs_tbl(counter).QUAL_TYPE_ID
        , l_terr_qtype_usgs_tbl(counter).QUALIFIER_TYPE_NAME
        , l_terr_qtype_usgs_tbl(counter).QUALIFIER_TYPE_DESCRIPTION;

        EXIT WHEN get_terr_qtype_usgs%NOTFOUND;

        --dbms_output.put_line( 'get_terr_qtype_usgs: counter = '|| counter ||
        --                     ' terr_qtype_usg = ' ||
        --                     l_terr_qtype_usgs_tbl(counter).qual_type_usg_id ||
        --                     ' transaction = ' ||
        --                     l_terr_qtype_usgs_tbl(counter).qualifier_type_description);

        counter := counter + 1;

    END LOOP;
    CLOSE get_terr_qtype_usgs;

   --dbms_output.put_line( 'AFTER get_terr_qtype_usgs: counter = '|| counter );

    /****************************/
    /* get territory qualifiers */
    /****************************/
    counter := 0;

    OPEN get_terr_qual(p_terr_id);
    LOOP
        FETCH get_terr_qual INTO
          l_terr_qual_tbl(counter).TERR_QUAL_ID
        , l_terr_qual_tbl(counter).LAST_UPDATE_DATE
        , l_terr_qual_tbl(counter).LAST_UPDATED_BY
        , l_terr_qual_tbl(counter).CREATION_DATE
        , l_terr_qual_tbl(counter).CREATED_BY
        , l_terr_qual_tbl(counter).LAST_UPDATE_LOGIN
        , l_terr_qual_tbl(counter).TERR_ID
        , l_terr_qual_tbl(counter).QUAL_USG_ID
        , l_terr_qual_tbl(counter).USE_TO_NAME_FLAG
        , l_terr_qual_tbl(counter).GENERATE_FLAG
        , l_terr_qual_tbl(counter).OVERLAP_ALLOWED_FLAG
        , l_terr_qual_tbl(counter).QUALIFIER_MODE
        , l_terr_qual_tbl(counter).ORG_ID
        , l_terr_qual_tbl(counter).DISPLAY_TYPE
        , l_terr_qual_tbl(counter).LOV_SQL
        , l_terr_qual_tbl(counter).CONVERT_TO_ID_FLAG
        , l_terr_qual_tbl(counter).QUAL_TYPE_ID
        , l_terr_qual_tbl(counter).QUALIFIER_TYPE_NAME
        , l_terr_qual_tbl(counter).QUALIFIER_TYPE_DESCRIPTION
        , l_terr_qual_tbl(counter).QUALIFIER_NAME;

        EXIT WHEN get_terr_qual%NOTFOUND;

         --dbms_output.put_line( 'get_terr_qual: counter = '|| counter ||
         --                    ' terr_qual = ' || l_terr_qual_tbl(counter).qual_usg_id ||
         --                    ' qualifier_name = ' || l_terr_qual_tbl(counter).qualifier_name);

         counter := counter + 1;

    END LOOP;
    CLOSE get_terr_qual;

   --dbms_output.put_line( 'AFTER get_terr_qual: counter = '|| counter );

    /**********************************/
    /* get territory qualifier values */
    /**********************************/
    counter := 0;

    OPEN get_terr_values ( p_terr_id );
    LOOP
        FETCH get_terr_values INTO
          l_terr_values_tbl(counter).TERR_VALUE_ID
        , l_terr_values_tbl(counter).LAST_UPDATED_BY
        , l_terr_values_tbl(counter).LAST_UPDATE_DATE
        , l_terr_values_tbl(counter).CREATED_BY
        , l_terr_values_tbl(counter).CREATION_DATE
        , l_terr_values_tbl(counter).LAST_UPDATE_LOGIN
        , l_terr_values_tbl(counter).TERR_QUAL_ID
        , l_terr_values_tbl(counter).INCLUDE_FLAG
        , l_terr_values_tbl(counter).COMPARISON_OPERATOR
        , l_terr_values_tbl(counter).ID_USED_FLAG
        , l_terr_values_tbl(counter).LOW_VALUE_CHAR_ID
        , l_terr_values_tbl(counter).LOW_VALUE_CHAR
        , l_terr_values_tbl(counter).HIGH_VALUE_CHAR
        , l_terr_values_tbl(counter).LOW_VALUE_NUMBER
        , l_terr_values_tbl(counter).HIGH_VALUE_NUMBER
        , l_terr_values_tbl(counter).VALUE_SET
        , l_terr_values_tbl(counter).INTEREST_TYPE_ID
        , l_terr_values_tbl(counter).PRIMARY_INTEREST_CODE_ID
        , l_terr_values_tbl(counter).SECONDARY_INTEREST_CODE_ID
        , l_terr_values_tbl(counter).CURRENCY_CODE
        , l_terr_values_tbl(counter).ORG_ID;

        EXIT WHEN get_terr_values%NOTFOUND;

        --dbms_output.put_line( 'get_terr_values: counter = '|| counter ||
        --                      ' terr_value = ' || l_terr_values_tbl(counter).terr_value_id);

        counter := counter + 1;

    END LOOP;
    CLOSE get_terr_values;

   --dbms_output.put_line( 'AFTER get_terr_values: counter = '|| counter );

    /***************************/
    /* get territory resources */
    /***************************/
    counter := 0;

    OPEN get_terr_rsc ( p_terr_id );
    LOOP
        FETCH get_terr_rsc INTO
          l_terr_rsc_tbl(counter).TERR_RSC_ID
        , l_terr_rsc_tbl(counter).LAST_UPDATE_DATE
        , l_terr_rsc_tbl(counter).LAST_UPDATED_BY
        , l_terr_rsc_tbl(counter).CREATION_DATE
        , l_terr_rsc_tbl(counter).CREATED_BY
        , l_terr_rsc_tbl(counter).LAST_UPDATE_LOGIN
        , l_terr_rsc_tbl(counter).TERR_ID
        , l_terr_rsc_tbl(counter).RESOURCE_ID
        , l_terr_rsc_tbl(counter).RESOURCE_TYPE
        , l_terr_rsc_tbl(counter).ROLE
        , l_terr_rsc_tbl(counter).PRIMARY_CONTACT_FLAG
        , l_terr_rsc_tbl(counter).START_DATE_ACTIVE
        , l_terr_rsc_tbl(counter).END_DATE_ACTIVE
        , l_terr_rsc_tbl(counter).FULL_ACCESS_FLAG
        , l_terr_rsc_tbl(counter).ORG_ID
        , l_terr_rsc_tbl(counter).RESOURCE_NAME;

        EXIT WHEN get_terr_rsc%NOTFOUND;

        --dbms_output.put_line( 'get_terr_rsc: counter = '|| counter ||
        --                     ' terr_rsc = ' || l_terr_rsc_tbl(counter).terr_rsc_id ||
        --                     ' resource_name = ' || l_terr_rsc_tbl(counter).resource_name);

        counter := counter + 1;

    END LOOP;
    CLOSE get_terr_rsc;

   --dbms_output.put_line( 'AFTER get_terr_rsc: counter = '|| counter );

    /* save return variables */
    x_terr_rec  := l_terr_rec;
    x_terr_type_rec := l_terr_type_rec;
    x_terr_sub_terr_tbl := l_terr_sub_terr_tbl;
    x_terr_usgs_tbl := l_terr_usgs_tbl;
    x_terr_qtype_usgs_tbl := l_terr_qtype_usgs_tbl;
    x_terr_qual_tbl := l_terr_qual_tbl;
    x_terr_values_tbl := l_terr_values_tbl;
    x_terr_rsc_tbl := l_terr_rsc_tbl;

    /* save return status */
    x_return_status := l_return_status;

    --dbms_output.put_line( 'get_terr: END return_status = '|| l_return_status );

    /**********************************************************************************************
    ** API BODY END
    ***********************************************************************************************/

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
        FND_MSG_PUB.Add;
    END IF;

    /* Standard call to get message count and if count is 1, get message info. */
    FND_MSG_PUB.Count_And_Get
    (   p_count          =>   x_msg_count,
        p_data           =>   x_msg_data
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        --dbms_output.put_line( 'FND_API.G_EXC_ERROR: return_status = '|| x_return_status );

        FND_MSG_PUB.Count_And_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
        );


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        --dbms_output.put_line( 'FND_API.G_RET_STS_UNEXP_ERROR: return_status = '|| x_return_status );

        FND_MSG_PUB.Count_And_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
        );

    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         --dbms_output.put_line( 'OTHERS: return_status = '|| x_return_status );
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;

         FND_MSG_PUB.Count_And_Get
         ( p_count         =>      x_msg_count,
           p_data          =>      x_msg_data
         );

END Get_Territory_Details;


--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Get_Escalation_Territory
--    Type      : PUBLIC
--    Function  : To get a territory's escalation territory
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      p_Escalation_Terr_Id       NUMBER
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--      p_Commit                   VARCHAR2                         FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name             Data Type
--      x_Return_Status            VARCHAR2(1)
--      x_Msg_Count                NUMBER
--      x_Msg_Data                 VARCHAR2(2000)
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Get_Escalation_Territory (
    p_Api_Version                IN   NUMBER,
    p_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_terr_id                    IN   NUMBER := FND_API.G_MISS_NUM,
    x_escalation_terr_id         OUT  NOCOPY NUMBER
)
IS

    l_api_name                CONSTANT VARCHAR2(30) := 'Get_Escalation_Territory';
    l_api_version             CONSTANT NUMBER   := 1.0;

    /* cursor to return escalation terr id */
    CURSOR c_esc_terr_id ( p_terr_id NUMBER )
    IS
    /* modified for R12 as there is no concept of escalation territory for R12 , instead */
    /* resources will be assigned to the territory as escalation owner                   */
    /* SELECT jt.escalation_territory_id */
    SELECT jt.terr_id
    FROM jtf_terr_all jt
    WHERE jt.terr_id = p_terr_id
      AND NVL(jt.end_date_active, sysdate+1) > sysdate
      AND NVL(jt.start_date_active, sysdate-1) < sysdate;

    /* cursor return variable */
    esc_csr     NUMBER;

    /* Status local variable */
    l_return_status         VARCHAR2(1);

    /* local scratch variable */
    l_escalation_terr_id    NUMBER;

BEGIN
    /* Standard call to check for call compatibility */
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /* Initialize message list if p_init_msg_list is set to TRUE */
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
        FND_MSG_PUB.Add;
    END IF;


    /**********************************************************************************************
    ** API BODY START
    ***********************************************************************************************/

    /* Initialize API return status to SUCCESS */
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_esc_terr_id (p_terr_id);
    FETCH c_esc_terr_id INTO esc_csr;
    IF c_esc_terr_id%NOTFOUND THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        -- Debug message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            FND_MESSAGE.Set_Name ('JTF',  'JTF_TERR_ESC_TERR_NOT_FOUND');
            FND_MSG_PUB.ADD;
        END IF;

    ELSE

        l_escalation_terr_id := esc_csr;

    END IF;

    CLOSE c_esc_terr_id;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    /* save return variable */
    x_escalation_terr_id  := l_escalation_terr_id;

    /* save return status */
    x_return_status := l_return_status;

    /**********************************************************************************************
    ** API BODY END
    ***********************************************************************************************/

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
        FND_MSG_PUB.Add;
    END IF;

    /* Standard call to get message count and if count is 1, get message info. */
    FND_MSG_PUB.Count_And_Get
    (   p_count          =>   x_msg_count,
        p_data           =>   x_msg_data
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;

        FND_MSG_PUB.Count_And_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
        );


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
        );

    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;

         FND_MSG_PUB.Count_And_Get
         ( p_count         =>      x_msg_count,
           p_data          =>      x_msg_data
         );

END Get_Escalation_Territory;


--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Get_Parent_Territory
--    Type      : PUBLIC
--    Function  : To get a territory's parent territory
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      p_Parent_Terr_Id           NUMBER
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--      p_Commit                   VARCHAR2                         FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name             Data Type
--      x_Return_Status            VARCHAR2(1)
--      x_Msg_Count                NUMBER
--      x_Msg_Data                 VARCHAR2(2000)
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Get_Parent_Territory (
    p_Api_Version                IN   NUMBER,
    p_Init_Msg_List              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT  NOCOPY VARCHAR2,
    x_msg_count                  OUT  NOCOPY NUMBER,
    x_msg_data                   OUT  NOCOPY VARCHAR2,
    p_terr_id                    IN   NUMBER := FND_API.G_MISS_NUM,
    x_parent_terr_id             OUT  NOCOPY NUMBER
)
IS

    l_api_name                CONSTANT VARCHAR2(30) := 'Get_Parent_Territory';
    l_api_version             CONSTANT NUMBER   := 1.0;

    /* cursor to return escalation terr id */
    CURSOR c_parent_terr_id ( p_terr_id NUMBER )
    IS
    SELECT jt.parent_territory_id
    FROM jtf_terr_all jt
    WHERE jt.terr_id = p_terr_id;

    /* cursor return vraiable */
    par_csr     NUMBER;

    /* Status local variable */
    l_return_status         VARCHAR2(1);

    /* local scratch variable */
    l_parent_terr_id    NUMBER;


BEGIN
    /* Standard call to check for call compatibility */
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME)
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    /* Initialize message list if p_init_msg_list is set to TRUE */
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF;

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
        FND_MSG_PUB.Add;
    END IF;

    /**********************************************************************************************
    ** API BODY START
    ***********************************************************************************************/

    /* Initialize API return status to SUCCESS */
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN c_parent_terr_id (p_terr_id);
    FETCH c_parent_terr_id INTO par_csr;
    IF c_parent_terr_id%NOTFOUND THEN

        l_return_status := FND_API.G_RET_STS_ERROR;

        -- Debug message
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
            FND_MESSAGE.Set_Name ('JTF',  'JTF_TERR_PARENT_NOT_FOUND');
            FND_MSG_PUB.ADD;
        END IF;

    ELSE

        l_parent_terr_id := par_csr;

    END IF;

    CLOSE c_parent_terr_id;

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    /* save return variable */
    x_parent_terr_id  := l_parent_terr_id;

    /* save return status */
    x_return_status := l_return_status;

    /**********************************************************************************************
    ** API BODY END
    ***********************************************************************************************/

    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
        FND_MSG_PUB.Add;
    END IF;

    /* Standard call to get message count and if count is 1, get message info. */
    FND_MSG_PUB.Count_And_Get
    (   p_count          =>   x_msg_count,
        p_data           =>   x_msg_data
    );

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;

        FND_MSG_PUB.Count_And_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
        );


    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
        ( p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
        );

    WHEN OTHERS THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;

         FND_MSG_PUB.Count_And_Get
         ( p_count         =>      x_msg_count,
           p_data          =>      x_msg_data
         );

END Get_Parent_Territory;


--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Get_Escalation_TerrMembers
--    Type      : PUBLIC
--    Function  : To get reosurces attached with a escalation
--                territory
--
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      p_Terr_Id                  NUMBER
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--      p_Commit                   VARCHAR2                         FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name             Data Type
--      x_Return_Status            VARCHAR2(1)
--      x_Msg_Count                NUMBER
--      x_Msg_Data                 VARCHAR2(2000)
--
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Get_Escalation_TerrMembers
 (p_api_version_number      IN  NUMBER,
  p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,
  p_commit                  IN  VARCHAR2 := FND_API.G_FALSE,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  p_terr_id                 IN  NUMBER,
  x_QualifyingRsc_out_tbl   OUT NOCOPY QualifyingRsc_out_tbl_type,
  p_access_type 			IN VARCHAR2 DEFAULT NULL)
 AS
      l_api_name                   CONSTANT VARCHAR2(30) := 'Get_Escalation_TerrMembers';
      l_api_version_number         CONSTANT NUMBER       := 1.0;
      l_return_status              VARCHAR2(1);

      l_QualifyingRsc_out_rec      QualifyingRsc_out_rec_type;

      --Declare cursor to get resource accesses
      Cursor C_GetTerrRsc IS
            Select JTR.TERR_RSC_ID,
                  JTR.TERR_ID,
                  JT.NAME,
                  JTR.RESOURCE_ID,
                  --JTRA.ACCESS_TYPE,
                  JTR.RESOURCE_TYPE,
                  JTR.ROLE,
				  decode(JTRA.trans_access_code, 'ESC_OWNER', 'Y', 'ESCALATION', 'N', 'N') PRIMARY_CONTACT_FLAG
                  --JTR.PRIMARY_CONTACT_FLAG
            From  JTF_TERR_RSC_ALL JTR,
                  JTF_TERR_RSC_ACCESS_ALL JTRA,
                  JTF_TERR_ALL JT
            Where JT.TERR_ID = p_Terr_id
            AND JTR.TERR_ID = JT.TERR_ID
            AND JTR.TERR_RSC_ID = JTRA.TERR_RSC_ID
            AND NVL(jtr.end_date_active, sysdate+1) > sysdate
            AND NVL(jtr.start_date_active, sysdate-1) < sysdate
            AND NVL(jt.end_date_active, sysdate+1) > sysdate
            AND NVL(jt.start_date_active, sysdate-1) < sysdate
			AND JTRA.trans_access_code IN ('ESC_OWNER', 'ESCALATION')
			AND (jtra.access_type = p_access_type OR p_access_type IS NULL);
			/*
            AND EXISTS (
                 SELECT 1
                 FROM   JTF_TERR_RSC_ACCESS_ALL JTRA
                 WHERE  JTRA.terr_rsc_id = JTR.terr_rsc_id
                 AND    JTRA.trans_access_code IN ('ESC_OWNER', 'ESCALATION'));
				 */


      l_Counter   NUMBER := 1;

 BEGIN
      --dbms_output.put_line('Get_Escalation_TerrMembers: Entering the API');

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
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
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_START_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
        FND_MSG_PUB.Add;
    END IF;
      --
      -- API body
      --
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      for res_rec in C_GetTerrRsc
           loop

            x_QualifyingRsc_out_tbl(l_Counter).terr_rsc_id := res_rec.terr_rsc_id;
            x_QualifyingRsc_out_tbl(l_Counter).terr_id := res_rec.terr_id;
            x_QualifyingRsc_out_tbl(l_Counter).terr_name := res_rec.name;
            x_QualifyingRsc_out_tbl(l_Counter).resource_id := res_rec.resource_id;
            x_QualifyingRsc_out_tbl(l_Counter).resource_type := res_rec.resource_type;
            x_QualifyingRsc_out_tbl(l_Counter).role := res_rec.role;
            x_QualifyingRsc_out_tbl(l_Counter).primary_contact_flag := res_rec.primary_contact_flag;

            l_Counter := l_Counter + 1;

           end loop;
      --
      If l_Counter = 1 Then
         null;
         --dbms_output.put_line('No records returned');
      End If;
      --
    /* Debug Message */
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW)
    THEN
        FND_MESSAGE.Set_Name('JTF', 'JTF_TERR_END_MSG');
        FND_MESSAGE.Set_Token('PROC_NAME', l_api_name);
        FND_MSG_PUB.Add;
    END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (   p_count           =>      x_msg_count,
          p_data            =>      x_msg_data
      );
      --dbms_output.put_line('Get_Escalation_TerrMembers: Exiting the API');
  EXCEPTION
  --
      WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
           IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
           END IF;
           FND_MSG_PUB.Count_And_Get
           ( p_count         =>      x_msg_count,
             p_data          =>      x_msg_data
           );
    --
END Get_Escalation_TerrMembers;

End JTF_TERRITORY_GET_PUB; /* End of Package Body */

/
