--------------------------------------------------------
--  DDL for Package JTF_TERRITORY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERRITORY_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfpters.pls 120.3.12010000.3 2009/09/07 06:29:34 vpalle ship $ */
/*#
 * This package provides the public APIs for creating a territory or
 * assigning resources and their access information to a territory.
 * @rep:scope public
 * @rep:product JTY
 * @rep:lifecycle active
 * @rep:displayname Create Territory and Assign Resources
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY JTY_TERRITORY
 */
--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERRITORY_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This package is a public API for inserting territory
--      related information IN to information into JTF tables.
--      It contains specification for pl/sql records and tables
--      and the Public territory related API's.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      06/09/99    VNEDUNGA      Created
--      07/15/99    JDOCHERT      Updated existing APIs and
--                                added new APIs
--      12/09/99    VNEDUNGA      Modifying TASK record defnition
--      01/05/99    VNEDUNGA      Changing the records def for lead/oppor
--      01/10/00    VNEDUNGA      Changes to serv_req/srv_task as per
--                                new qualifer list
--      01/10/00    VNEDUNGA      Correcting the DEF_MGMT rec type defnition
--      01/10/00    VNEDUNGA      Adding language_code_id to DEF_MGMT rec type
--      01/11/00    VNEDUNGA      Changing the servic req and
--                                Serv Req + Task rec def
--      01/12/00    VNEDUNGA      Adding currency code to lead/oppr rec type
--      01/12/00    VNEDUNGA      Changing Defect Rec type
--      01/17/00    VNEDUNGA      deleteing service request id for task
--      03/22/00    VNEDUNGA      Adding FULL_ACCESS_FLAG to resource record
--                                and winning terr rec defnitions
--      05/04/00    VNEDUNGA      Added pricing_date
--      05/04/00    VNEDUNGA      Changing Area_code from varchar2(05) - 10
--      06/08/00    VNEDUNGA      Adding group_id to resource record defnition
--      07/17/00    JDOCHERT      Adding Contract Renewal record type for OKS
--      09/18/00    JDOCHERT      BUG#1408610 FIX
--      10/30/00    JDOCHERT      BUG#1478215 FIX
--      07/20/2001  EIHSU         CHANGED all char_XXlist to char360list for
--                                easier maintainability and purposes of JTF_TERR_ASSIGN_PUB
--      09/27/01    ARPATEL       changed all char1list to char360list
--      12/03/04    achanda       changed the record JTF_Serv_Req_rec_type and JTF_Srv_Task_rec_type to include
--                                fields for component and subcomponent : bug # 3726007
--      12/31/08    Gmarwah       changed the record JTF_Serv_Req_rec_type and JTF_Srv_Task_rec_type to include
--                                fields for Time OF Day and Day OF week Qualifiers. Refer Bug 	7676184
--
--    End of Comments
--



--*******************************************************
--                     Composite Types
--*******************************************************
--
--    Start of Comments
---------------------------------------------------------
-- For ORACLE SALES
---------------------------------------------------------
/* START OF 10/30/00    JDOCHERT      BUG#1478215 FIX */
/* These types have been created outside the package
** on the database as a workaround for:
** If type created internally with procedure PL/SQL error raised
** PLS-00457: in USING clause expressions have to be of SQL types
** They are listed here for informational purposes
CREATE TYPE jtf_terr_date_list           IS VARRAY(1000000) OF DATE;
CREATE TYPE jtf_terr_number_list         IS VARRAY(1000000) OF NUMBER;
CREATE TYPE jtf_terr_char_1list          IS VARRAY(1000000) OF VARCHAR2(1);
CREATE TYPE jtf_terr_char_360list         IS VARRAY(1000000) OF VARCHAR2(15);
CREATE TYPE jtf_terr_char_360list         IS VARRAY(1000000) OF VARCHAR2(25);
CREATE TYPE jtf_terr_char_360list         IS VARRAY(1000000) OF VARCHAR2(30);
CREATE TYPE jtf_terr_char_360list         IS VARRAY(1000000) OF VARCHAR2(60);
CREATE TYPE jtf_terr_char_360list        IS VARRAY(1000000) OF VARCHAR2(150);
CREATE TYPE jtf_terr_char_255list        IS VARRAY(1000000) OF VARCHAR2(255);
************************************************************************/



---------------------------------------------------------
--               GENERIC BULK record format
---------------------------------------------------------
TYPE jtf_bulk_trans_rec_type         IS RECORD
    (
      TRANS_OBJECT_ID                jtf_terr_number_list         := jtf_terr_number_list(),
      TRANS_DETAIL_OBJECT_ID         jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_CHAR01                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR02                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR03                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR04                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR05                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR06                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR07                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR08                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR09                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR10                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR11                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR12                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR13                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR14                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR15                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR16                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR17                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR18                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR19                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR20                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR21                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR22                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR23                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR24                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CHAR25                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_NUM01                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM02                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM03                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM04                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM05                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM06                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM07                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM08                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM09                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM10                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM11                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM12                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM13                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM14                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM15                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM16                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM17                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM18                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM19                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM20                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM21                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM22                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM23                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM24                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM25                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM26                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM27                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM28                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM29                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM30                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM31                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM32                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM33                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM34                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM35                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM36                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM37                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM38                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM39                    jtf_terr_number_list         := jtf_terr_number_list(),
      SQUAL_NUM40                    jtf_terr_number_list         := jtf_terr_number_list(),

      SQUAL_CURC01                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CURC02                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CURC03                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CURC04                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      SQUAL_CURC05                   jtf_terr_char_360list        := jtf_terr_char_360list()

    );


---------------------------------------------------------
--               Winning Territory record format
---------------------------------------------------------
 TYPE WINNING_BULK_REC_TYPE IS RECORD (
      party_id               jtf_terr_number_list         := jtf_terr_number_list(),
      party_site_id          jtf_terr_number_list         := jtf_terr_number_list(),
      trans_object_id        jtf_terr_number_list         := jtf_terr_number_list(),
      trans_detail_object_id jtf_terr_number_list         := jtf_terr_number_list(),
      terr_id                jtf_terr_number_list         := jtf_terr_number_list(),
      absolute_rank          jtf_terr_number_list         := jtf_terr_number_list(),
      terr_rsc_id            jtf_terr_number_list         := jtf_terr_number_list(),
      resource_id            jtf_terr_number_list         := jtf_terr_number_list(),
      resource_type          jtf_terr_char_360list         := jtf_terr_char_360list(),
      group_id               jtf_terr_number_list         := jtf_terr_number_list(),
      role                   jtf_terr_char_360list         := jtf_terr_char_360list(),
      full_access_flag       jtf_terr_char_360list          := jtf_terr_char_360list(),
      primary_contact_flag   jtf_terr_char_360list          := jtf_terr_char_360list()
 );



   TYPE JTF_WIN_RSC_BULK_REC_TYPE IS RECORD
   ( resource_id          DBMS_SQL.NUMBER_TABLE,
     resource_name        DBMS_SQL.VARCHAR2_TABLE,
     resource_job_title   DBMS_SQL.VARCHAR2_TABLE,
     resource_phone       DBMS_SQL.VARCHAR2_TABLE,
     resource_email       DBMS_SQL.VARCHAR2_TABLE,
     resource_mgr_name    DBMS_SQL.VARCHAR2_TABLE,
     resource_mgr_phone   DBMS_SQL.VARCHAR2_TABLE,
     resource_mgr_email   DBMS_SQL.VARCHAR2_TABLE,
     terr_id              DBMS_SQL.NUMBER_TABLE,
     absolute_rank        DBMS_SQL.NUMBER_TABLE,
     top_level_terr_id    DBMS_SQL.NUMBER_TABLE,
     resource_property1   DBMS_SQL.VARCHAR2_TABLE,
     resource_property2   DBMS_SQL.VARCHAR2_TABLE,
     resource_property3   DBMS_SQL.VARCHAR2_TABLE,
     resource_property4   DBMS_SQL.VARCHAR2_TABLE
   );

---------------------------------------------------------
--        Winning Territory Record: WinningTerr_rec_type
--
--  Used for backward compatibility with pre 11.5.5 APIs
--
---------------------------------------------------------
  TYPE WinningTerrMember_rec_type   IS RECORD
    (
      TERR_RSC_ID                   NUMBER       := FND_API.G_MISS_NUM,
      RESOURCE_ID                   NUMBER       := FND_API.G_MISS_NUM,
      RESOURCE_TYPE                 VARCHAR2(60) := FND_API.G_MISS_CHAR,
      GROUP_ID                      NUMBER       := FND_API.G_MISS_NUM,
      ROLE                          VARCHAR2(60) := FND_API.G_MISS_CHAR,
      START_DATE                    DATE         := FND_API.G_MISS_DATE,
      END_DATE                      DATE         := FND_API.G_MISS_DATE,
      PRIMARY_CONTACT_FLAG          VARCHAR2(01) := FND_API.G_MISS_CHAR,
      FULL_ACCESS_FLAG              VARCHAR2(01) := FND_API.G_MISS_CHAR,
      TERR_ID                       NUMBER       := FND_API.G_MISS_NUM,
      TERR_NAME                     VARCHAR2(60) := FND_API.G_MISS_CHAR,
      ABSOLUTE_RANK                 NUMBER       := FND_API.G_MISS_NUM
    );

  G_MISS_WINNINGTERRMEMBER_REC      WinningTerrMember_rec_type;

  TYPE WinningTerrMember_tbl_type   IS TABLE OF   WinningTerrMember_rec_type
                                    INDEX BY BINARY_INTEGER;

  G_MISS_WINNINGTERRMEMBER_TBL      WinningTerrMember_tbl_type;



---------------------------------------------------------
--        Winning Territory Record: WinningTerr_rec_type
--
--  Used for backward compatibility with
--  GetWinningTerritories API for Oracle Sales/Accounts
--  used by AMS.
-----------------------------------------------------------
  TYPE WinningTerr_rec_type     IS RECORD
    (
      PARTY_ID                  NUMBER         := FND_API.G_MISS_NUM,
      PARTY_SITE_ID             NUMBER         := FND_API.G_MISS_NUM,
      TERR_ID                   NUMBER         := FND_API.G_MISS_NUM,
      TERR_NAME                 VARCHAR2(2000) := FND_API.G_MISS_CHAR,
      RANK                      NUMBER         := FND_API.G_MISS_NUM,
      START_DATE_ACTIVE         DATE           := FND_API.G_MISS_DATE,
      END_DATE_ACTIVE           DATE           := FND_API.G_MISS_DATE,
      ORG_ID                    NUMBER         := FND_API.G_MISS_NUM,
      PARENT_TERRITORY_ID       NUMBER         := FND_API.G_MISS_NUM,
      TEMPLATE_TERRITORY_ID     NUMBER         := FND_API.G_MISS_NUM,
      ESCALATION_TERRITORY_ID   NUMBER         := FND_API.G_MISS_NUM
    );

  G_MISS_WINNINGTERR_REC        WinningTerr_rec_type;

  TYPE WinningTerr_tbl_type     IS TABLE OF   WinningTerr_rec_type
                                INDEX BY BINARY_INTEGER;

  G_MISS_WINNINGTERR_TBL        WinningTerr_tbl_type;




---------------------------------------------------------
--               Account BULK record format
---------------------------------------------------------
  TYPE JTF_ACCOUNT_BULK_REC_TYPE IS RECORD (

      /* 2167091 BUG FIX: JDOCHERT: 01/17/02 */
      TRANS_OBJECT_ID    jtf_terr_number_list  := jtf_terr_number_list(),

      city                   jtf_terr_char_360list         := jtf_terr_char_360list(),
      postal_code            jtf_terr_char_360list         := jtf_terr_char_360list(),
      state                  jtf_terr_char_360list         := jtf_terr_char_360list(),
      province               jtf_terr_char_360list         := jtf_terr_char_360list(),
      county                 jtf_terr_char_360list         := jtf_terr_char_360list(),
      country                jtf_terr_char_360list         := jtf_terr_char_360list(),
      interest_type_id       jtf_terr_number_list         := jtf_terr_number_list (),
      primary_interest_id    jtf_terr_number_list         := jtf_terr_number_list (),
      secondary_interest_id  jtf_terr_number_list         := jtf_terr_number_list (),
      party_id               jtf_terr_number_list         := jtf_terr_number_list (),
      party_site_id          jtf_terr_number_list         := jtf_terr_number_list (),
      area_code              jtf_terr_char_360list         := jtf_terr_char_360list (),
      comp_name_range        jtf_terr_char_360list        := jtf_terr_char_360list(),
      partner_id             jtf_terr_number_list         := jtf_terr_number_list (),
      num_of_employees       jtf_terr_number_list         := jtf_terr_number_list (),
      category_code          jtf_terr_char_360list         := jtf_terr_char_360list(),
      party_relationship_id  jtf_terr_number_list         := jtf_terr_number_list (),
      sic_code               jtf_terr_char_360list         := jtf_terr_char_360list(),
      attribute1             jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute2             jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute3             jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute4             jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute5             jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute6             jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute7             jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute8             jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute9             jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute10            jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute11            jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute12            jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute13            jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute14            jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute15            jtf_terr_char_360list        := jtf_terr_char_360list(),
      org_id                 jtf_terr_number_list         := jtf_terr_number_list(),

      /* JDOCHERT 040901 - Bug#1697951 FIX: */
      /* Company Annual Revenue */
      squal_num06            jtf_terr_number_list         := jtf_terr_number_list(),
      car_currency_code      jtf_terr_char_360list         := jtf_terr_char_360list(),

      squal_num01            jtf_terr_number_list         := jtf_terr_number_list(),

      /* DUNS#: BUG#2933116: JDOCHERT: 05/20/03 */
      SQUAL_CHAR11           jtf_terr_char_360list        := jtf_terr_char_360list(),

      /* ARPATEL, 10/17/03: bug#3200912 Quote/Product Category */
      squal_num50            jtf_terr_number_list         := jtf_terr_number_list()

     );

---------------------------------------------------------
--               Lead record format
---------------------------------------------------------
  TYPE JTF_Lead_BULK_rec_type             IS RECORD
    (

      /* 2167091 BUG FIX: JDOCHERT: 01/17/02 */
      TRANS_OBJECT_ID               jtf_terr_number_list  := jtf_terr_number_list(),

      sales_lead_id                 jtf_terr_number_list         := jtf_terr_number_list(),
      sales_lead_line_id            jtf_terr_number_list         := jtf_terr_number_list(),
      city                          jtf_terr_char_360list         := jtf_terr_char_360list(),
      postal_code                   jtf_terr_char_360list         := jtf_terr_char_360list(),
      state                         jtf_terr_char_360list         := jtf_terr_char_360list(),
      province                      jtf_terr_char_360list         := jtf_terr_char_360list(),
      county                        jtf_terr_char_360list         := jtf_terr_char_360list(),
      country                       jtf_terr_char_360list         := jtf_terr_char_360list(),
      interest_type_id              jtf_terr_number_list         := jtf_terr_number_list(),
      primary_interest_id           jtf_terr_number_list         := jtf_terr_number_list(),
      secondary_interest_id         jtf_terr_number_list         := jtf_terr_number_list(),
      party_id                      jtf_terr_number_list         := jtf_terr_number_list(),
      party_site_id                 jtf_terr_number_list         := jtf_terr_number_list(),
      area_code                     jtf_terr_char_360list         := jtf_terr_char_360list (),
      comp_name_range               jtf_terr_char_360list        := jtf_terr_char_360list(),
      partner_id                    jtf_terr_number_list         := jtf_terr_number_list(),
      num_of_employees              jtf_terr_number_list         := jtf_terr_number_list(),
      category_code                 jtf_terr_char_360list         := jtf_terr_char_360list(),
      party_relationship_id         jtf_terr_number_list         := jtf_terr_number_list(),
      sic_code                      jtf_terr_char_360list         := jtf_terr_char_360list(),
      budget_amount                 jtf_terr_number_list         := jtf_terr_number_list(),
      currency_code                 jtf_terr_char_360list         := jtf_terr_char_360list(),
      pricing_date                  jtf_terr_date_list           := jtf_terr_date_list(),
      source_promotion_id           jtf_terr_number_list         := jtf_terr_number_list(),
      inventory_item_id             jtf_terr_number_list         := jtf_terr_number_list(),
      lead_interest_type_id         jtf_terr_number_list         := jtf_terr_number_list(),
      lead_primary_interest_id      jtf_terr_number_list         := jtf_terr_number_list(),
      lead_secondary_interest_id    jtf_terr_number_list         := jtf_terr_number_list(),
      purchase_amount               jtf_terr_number_list         := jtf_terr_number_list(),
      attribute1                    jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute2                    jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute3                    jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute4                    jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute5                    jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute6                    jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute7                    jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute8                    jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute9                    jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute10                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute11                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute12                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute13                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute14                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute15                   jtf_terr_char_360list        := jtf_terr_char_360list(),
      org_id                        jtf_terr_number_list         := jtf_terr_number_list(),

      /* JDOCHERT 040901 - Bug#1697951 FIX: */
      /* Company Annual Revenue */
      squal_num06            jtf_terr_number_list         := jtf_terr_number_list(),
      car_currency_code      jtf_terr_char_360list         := jtf_terr_char_360list(),

      squal_num01            jtf_terr_number_list         := jtf_terr_number_list(),

      /* DUNS#: BUG#2933116: JDOCHERT: 05/20/03 */
      SQUAL_CHAR11           jtf_terr_char_360list        := jtf_terr_char_360list(),

      /* SALES CHANNEL: BUG#2725578: JDOCHERT: 08/11/03 */
      SQUAL_CHAR30           jtf_terr_char_360list        := jtf_terr_char_360list()

    );

---------------------------------------------------------
--               Opportunity record format
---------------------------------------------------------
  TYPE JTF_OPPOR_BULK_REC_TYPE IS RECORD (


      /* 2167091 BUG FIX: JDOCHERT: 01/17/02 */
      TRANS_OBJECT_ID                   jtf_terr_number_list  := jtf_terr_number_list(),

      lead_id                           jtf_terr_number_list         := jtf_terr_number_list (),
      lead_line_id                      jtf_terr_number_list         := jtf_terr_number_list (),
      city                              jtf_terr_char_360list         := jtf_terr_char_360list(),
      postal_code                       jtf_terr_char_360list         := jtf_terr_char_360list(),
      state                             jtf_terr_char_360list         := jtf_terr_char_360list(),
      province                          jtf_terr_char_360list         := jtf_terr_char_360list(),
      county                            jtf_terr_char_360list         := jtf_terr_char_360list(),
      country                           jtf_terr_char_360list         := jtf_terr_char_360list(),
      interest_type_id                  jtf_terr_number_list         := jtf_terr_number_list (),
      primary_interest_id               jtf_terr_number_list         := jtf_terr_number_list (),
      secondary_interest_id             jtf_terr_number_list         := jtf_terr_number_list (),
      party_id                          jtf_terr_number_list         := jtf_terr_number_list (),
      party_site_id                     jtf_terr_number_list         := jtf_terr_number_list (),
      area_code                         jtf_terr_char_360list         := jtf_terr_char_360list (),
      comp_name_range                   jtf_terr_char_360list         := jtf_terr_char_360list(),
      partner_id                        jtf_terr_number_list         := jtf_terr_number_list (),
      num_of_employees                  jtf_terr_number_list         := jtf_terr_number_list (),
      category_code                     jtf_terr_char_360list          := jtf_terr_char_360list(),
      party_relationship_id             jtf_terr_number_list         := jtf_terr_number_list (),
      sic_code                          jtf_terr_char_360list          := jtf_terr_char_360list(),
      target_segment_current            jtf_terr_char_360list          := jtf_terr_char_360list(),
      total_amount                      jtf_terr_number_list         := jtf_terr_number_list (),
      currency_code                     jtf_terr_char_360list          := jtf_terr_char_360list(),
      pricing_date                      jtf_terr_date_list            := jtf_terr_date_list(),
      channel_code                      jtf_terr_char_360list          := jtf_terr_char_360list(),
      inventory_item_id                 jtf_terr_number_list         := jtf_terr_number_list (),
      opp_interest_type_id              jtf_terr_number_list         := jtf_terr_number_list (),
      opp_primary_interest_id           jtf_terr_number_list         := jtf_terr_number_list (),
      opp_secondary_interest_id         jtf_terr_number_list         := jtf_terr_number_list (),
      opclss_interest_type_id           jtf_terr_number_list         := jtf_terr_number_list (),
      opclss_primary_interest_id        jtf_terr_number_list         := jtf_terr_number_list (),
      opclss_secondary_interest_id      jtf_terr_number_list         := jtf_terr_number_list (),
      attribute1                        jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute2                        jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute3                        jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute4                        jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute5                        jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute6                        jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute7                        jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute8                        jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute9                        jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute10                       jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute11                       jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute12                       jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute13                       jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute14                       jtf_terr_char_360list        := jtf_terr_char_360list(),
      attribute15                       jtf_terr_char_360list        := jtf_terr_char_360list(),
      org_id                            jtf_terr_number_list         := jtf_terr_number_list(),

      /* JDOCHERT 040901 - Bug#1697951 FIX: */
      /* Company Annual Revenue */
      squal_num06                       jtf_terr_number_list         := jtf_terr_number_list(),
      car_currency_code                 jtf_terr_char_360list         := jtf_terr_char_360list(),

      /* Campaign Code */
      squal_char40                      jtf_terr_char_360list        := jtf_terr_char_360list(),
      /* Opportunity Status */
      squal_char41                      jtf_terr_char_360list        := jtf_terr_char_360list(),

      /* JDOCHERT 060401 - Bug#1378393 FIX */
      /* Opportunity Promotion Identifier */
      squal_num40                       jtf_terr_number_list         := jtf_terr_number_list(),

      squal_num01                       jtf_terr_number_list         := jtf_terr_number_list(),
      squal_char01                      jtf_terr_char_360list        := jtf_terr_char_360list(),
      squal_char02                      jtf_terr_char_360list        := jtf_terr_char_360list(),

      /* DUNS#: BUG#2933116: JDOCHERT: 05/20/03 */
      SQUAL_CHAR11           jtf_terr_char_360list        := jtf_terr_char_360list()

     );

/* END OF 10/30/00    JDOCHERT      BUG#1478215 FIX */


--*******************************************************
--    Start of Comments
---------------------------------------------------------
--               Service request view record format
---------------------------------------------------------
--    Parameters:
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments

  TYPE JTF_Serv_Req_rec_type        IS RECORD
    (
      SERVICE_REQUEST_ID             NUMBER        := FND_API.G_MISS_NUM,
      PARTY_ID                       NUMBER        := FND_API.G_MISS_NUM,
      COUNTRY                        VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      PARTY_SITE_ID                  NUMBER        := FND_API.G_MISS_NUM,
      CITY                           VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      POSTAL_CODE                    VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      STATE                          VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      AREA_CODE                      VARCHAR2(10)  := FND_API.G_MISS_CHAR,
      COUNTY                         VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      COMP_NAME_RANGE                VARCHAR2(360) := FND_API.G_MISS_CHAR,
      PROVINCE                       VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      NUM_OF_EMPLOYEES               NUMBER        := FND_API.G_MISS_NUM,
      INCIDENT_TYPE_ID               NUMBER        := FND_API.G_MISS_NUM,
      INCIDENT_SEVERITY_ID           NUMBER        := FND_API.G_MISS_NUM,
      INCIDENT_URGENCY_ID            NUMBER        := FND_API.G_MISS_NUM,
      PROBLEM_CODE                   VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      INCIDENT_STATUS_ID             NUMBER        := FND_API.G_MISS_NUM,
      PLATFORM_ID                    NUMBER        := FND_API.G_MISS_NUM,
      SUPPORT_SITE_ID                NUMBER        := FND_API.G_MISS_NUM,
      CUSTOMER_SITE_ID               NUMBER        := FND_API.G_MISS_NUM,
      SR_CREATION_CHANNEL            VARCHAR2(150) := FND_API.G_MISS_CHAR,
      INVENTORY_ITEM_ID              NUMBER        := FND_API.G_MISS_NUM,
      ATTRIBUTE1                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE2                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE3                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE4                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE5                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE6                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE7                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE8                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE9                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE10                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE11                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE12                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE13                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE14                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE15                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ORGANIZATION_ID                NUMBER        := FND_API.G_MISS_NUM,


      /* Qualifier: SR Platform: */
      -- Inventory Item Id
      SQUAL_NUM12                    NUMBER        := FND_API.G_MISS_NUM,
      -- Organization Id
      SQUAL_NUM13                    NUMBER        := FND_API.G_MISS_NUM,

      /* Qualifier: SR Product Category: */
      -- Category Id
      SQUAL_NUM14                    NUMBER        := FND_API.G_MISS_NUM,

      /* Qualifier: SR Product, SR Product/Component/Subcomponent: */
      -- Inventory Item Id
      SQUAL_NUM15                    NUMBER        := FND_API.G_MISS_NUM,
      -- Organization Id
      SQUAL_NUM16                    NUMBER        := FND_API.G_MISS_NUM,
      -- Component
      SQUAL_NUM23                    NUMBER        := FND_API.G_MISS_NUM,
      -- Subcomponent
      SQUAL_NUM24                    NUMBER        := FND_API.G_MISS_NUM,

      /* Qualifier: SR Group Owner */
      SQUAL_NUM17                    NUMBER        := FND_API.G_MISS_NUM,

      /* Contract Support Service Item# */
      -- Inventory Item Id
      SQUAL_NUM18                   NUMBER        := FND_API.G_MISS_NUM,
      -- Organization Id
      SQUAL_NUM19                   NUMBER        := FND_API.G_MISS_NUM,

      /* VIP Customers */
      SQUAL_CHAR11                    VARCHAR2(360) := FND_API.G_MISS_CHAR,

      /* Qualifier: SR Problem Code */
      SQUAL_CHAR12                    VARCHAR2(360) := FND_API.G_MISS_CHAR,

       /* Qualifier: SR Customer Contact Preference */
      SQUAL_CHAR13                    VARCHAR2(360) := FND_API.G_MISS_CHAR,

       /* Qualifier: SR Service Contract Coverage */
      SQUAL_CHAR21                    VARCHAR2(360) := FND_API.G_MISS_CHAR,

      /* SR Language */
      SQUAL_CHAR20                    VARCHAR2(360) := FND_API.G_MISS_CHAR,

      SQUAL_NUM30                   NUMBER        := FND_API.G_MISS_NUM,

      /* Day Of Week */

      DAY_OF_WEEK                     VARCHAR2(360) := FND_API.G_MISS_CHAR,

      /*Time of Day */
      TIME_OF_DAY                       VARCHAR2(360) := FND_API.G_MISS_CHAR
    );


---------------------------------------------------------
--               Service Task view record format
---------------------------------------------------------
--    Parameters:
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments

  TYPE JTF_Task_rec_type             IS RECORD
    (
      TASK_ID                        NUMBER        := FND_API.G_MISS_NUM,
      PARTY_ID                       NUMBER        := FND_API.G_MISS_NUM,
      COUNTRY                        VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      PARTY_SITE_ID                  NUMBER        := FND_API.G_MISS_NUM,
      CITY                           VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      POSTAL_CODE                    VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      STATE                          VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      AREA_CODE                      VARCHAR2(10)  := FND_API.G_MISS_CHAR,
      COUNTY                         VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      COMP_NAME_RANGE                VARCHAR2(360) := FND_API.G_MISS_CHAR,
      PROVINCE                       VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      NUM_OF_EMPLOYEES               NUMBER        := FND_API.G_MISS_NUM,
      TASK_TYPE_ID                   NUMBER        := FND_API.G_MISS_NUM,
      TASK_STATUS_ID                 NUMBER        := FND_API.G_MISS_NUM,
      TASK_PRIORITY_ID               NUMBER        := FND_API.G_MISS_NUM,
      ATTRIBUTE1                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE2                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE3                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE4                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE5                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE6                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE7                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE8                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE9                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE10                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE11                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE12                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE13                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE14                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE15                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ORGANIZATION_ID                NUMBER        := FND_API.G_MISS_NUM
    );


---------------------------------------------------------
--               Service Service/Task view record format
---------------------------------------------------------
--    Parameters:
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments

    TYPE JTF_Srv_Task_rec_type         IS RECORD
    (
      TASK_ID                        NUMBER        := FND_API.G_MISS_NUM,
      SERVICE_REQUEST_ID             NUMBER        := FND_API.G_MISS_NUM,
      PARTY_ID                       NUMBER        := FND_API.G_MISS_NUM,
      COUNTRY                        VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      PARTY_SITE_ID                  NUMBER        := FND_API.G_MISS_NUM,
      CITY                           VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      POSTAL_CODE                    VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      STATE                          VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      AREA_CODE                      VARCHAR2(10)  := FND_API.G_MISS_CHAR,
      COUNTY                         VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      COMP_NAME_RANGE                VARCHAR2(360) := FND_API.G_MISS_CHAR,
      PROVINCE                       VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      NUM_OF_EMPLOYEES               NUMBER        := FND_API.G_MISS_NUM,
      TASK_TYPE_ID                   NUMBER        := FND_API.G_MISS_NUM,
      TASK_STATUS_ID                 NUMBER        := FND_API.G_MISS_NUM,
      TASK_PRIORITY_ID               NUMBER        := FND_API.G_MISS_NUM,
      INCIDENT_TYPE_ID               NUMBER        := FND_API.G_MISS_NUM,
      INCIDENT_SEVERITY_ID           NUMBER        := FND_API.G_MISS_NUM,
      INCIDENT_URGENCY_ID            NUMBER        := FND_API.G_MISS_NUM,
      PROBLEM_CODE                   VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      INCIDENT_STATUS_ID             NUMBER        := FND_API.G_MISS_NUM,
      PLATFORM_ID                    NUMBER        := FND_API.G_MISS_NUM,
      SUPPORT_SITE_ID                NUMBER        := FND_API.G_MISS_NUM,
      CUSTOMER_SITE_ID               NUMBER        := FND_API.G_MISS_NUM,
      SR_CREATION_CHANNEL            VARCHAR2(150) := FND_API.G_MISS_CHAR,
      INVENTORY_ITEM_ID              NUMBER        := FND_API.G_MISS_NUM,
      ATTRIBUTE1                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE2                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE3                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE4                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE5                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE6                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE7                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE8                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE9                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE10                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE11                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE12                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE13                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE14                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE15                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ORGANIZATION_ID                NUMBER        := FND_API.G_MISS_NUM,

      /* Qualifier: SR Platform: */
      -- Inventory Item Id
      SQUAL_NUM12                    NUMBER        := FND_API.G_MISS_NUM,
      -- Organization Id
      SQUAL_NUM13                    NUMBER        := FND_API.G_MISS_NUM,

      /* Qualifier: SR Product Category: */
      -- Category Id
      SQUAL_NUM14                    NUMBER        := FND_API.G_MISS_NUM,

      /* Qualifier: SR Product, SR Product/Component/Subcomponent: */
      -- Inventory Item Id
      SQUAL_NUM15                    NUMBER        := FND_API.G_MISS_NUM,
      -- Organization Id
      SQUAL_NUM16                    NUMBER        := FND_API.G_MISS_NUM,
      -- Component
      SQUAL_NUM23                    NUMBER        := FND_API.G_MISS_NUM,
      -- Subcomponent
      SQUAL_NUM24                    NUMBER        := FND_API.G_MISS_NUM,

      /* Qualifier: SR Group Owner */
      SQUAL_NUM17                    NUMBER        := FND_API.G_MISS_NUM,

      /* Contract Support Service Item# */
      -- Inventory Item Id
      SQUAL_NUM18                   NUMBER        := FND_API.G_MISS_NUM,
      -- Organization Id
      SQUAL_NUM19                   NUMBER        := FND_API.G_MISS_NUM,

      /* VIP Customers */
      SQUAL_CHAR11                    VARCHAR2(360) := FND_API.G_MISS_CHAR,

      /* Qualifier: SR Problem Code */
      SQUAL_CHAR12                    VARCHAR2(360) := FND_API.G_MISS_CHAR,

       /* Qualifier: SR Customer Contact Preference */
      SQUAL_CHAR13                    VARCHAR2(360) := FND_API.G_MISS_CHAR,

       /* Qualifier: SR Service Contract Coverage */
      SQUAL_CHAR21                    VARCHAR2(360) := FND_API.G_MISS_CHAR,

      /* SR Language */
      SQUAL_CHAR20                    VARCHAR2(360) := FND_API.G_MISS_CHAR,

      SQUAL_NUM30                   NUMBER        := FND_API.G_MISS_NUM,


      /* Day Of Week */

      DAY_OF_WEEK                     VARCHAR2(360) := FND_API.G_MISS_CHAR,

      /*Time of Day */
      TIME_OF_DAY                       VARCHAR2(360) := FND_API.G_MISS_CHAR
    );



--*******************************************************
--    Start of Comments
---------------------------------------------------------
--               Contract Renewal record type
---------------------------------------------------------
--    Parameters:
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments

  TYPE JTF_KREN_rec_type            IS RECORD
    (
      STATE                         VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      PARTY_ID                      NUMBER        := FND_API.G_MISS_NUM,
      COMP_NAME_RANGE               VARCHAR2(360) := FND_API.G_MISS_CHAR,
      ATTRIBUTE1                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE2                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE3                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE4                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE5                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE6                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE7                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE8                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE9                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE10                   VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE11                   VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE12                   VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE13                   VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE14                   VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE15                   VARCHAR2(150) := FND_API.G_MISS_CHAR
    );


--*******************************************************
--    Start of Comments
---------------------------------------------------------
--               Defect Management record format
---------------------------------------------------------
--    Parameters:
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments
  TYPE JTF_DEF_MGMT_rec_type         IS RECORD
    (
      SQUAL_CHAR01                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR02                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR03                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR04                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR05                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR06                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR07                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR08                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR09                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR10                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR11                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR12                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR13                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR14                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR15                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR16                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR17                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR18                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR19                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR20                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR21                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR22                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR23                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR24                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_CHAR25                   VARCHAR2(360) := FND_API.G_MISS_CHAR,
      SQUAL_NUM01                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM02                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM03                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM04                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM05                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM06                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM07                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM08                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM09                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM10                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM11                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM12                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM13                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM14                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM15                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM16                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM17                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM18                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM19                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM20                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM21                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM22                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM23                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM24                    NUMBER        := FND_API.G_MISS_NUM,
      SQUAL_NUM25                    NUMBER        := FND_API.G_MISS_NUM,
      ATTRIBUTE1                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE2                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE3                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE4                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE5                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE6                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE7                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE8                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE9                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE10                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE11                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE12                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE13                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE14                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE15                    VARCHAR2(150) := FND_API.G_MISS_CHAR
    );




--*******************************************************
--    Start of Comments
---------------------------------------------------------
--        Territory Resource Record: TerrResource_rec_type
---------------------------------------------------------
  TYPE TerrResource_rec_type     IS RECORD
    (
      TERR_RSC_ID                NUMBER        := FND_API.G_MISS_NUM,
      LAST_UPDATE_DATE           DATE          := FND_API.G_MISS_DATE,
      LAST_UPDATED_BY            NUMBER        := FND_API.G_MISS_NUM,
      CREATION_DATE              DATE          := FND_API.G_MISS_DATE,
      CREATED_BY                 NUMBER        := FND_API.G_MISS_NUM,
      LAST_UPDATE_LOGIN          NUMBER        := FND_API.G_MISS_NUM,
      TERR_ID                    NUMBER        := FND_API.G_MISS_NUM,
      RESOURCE_ID                NUMBER        := FND_API.G_MISS_NUM,
      GROUP_ID                   NUMBER        := FND_API.G_MISS_NUM,
      RESOURCE_TYPE              VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      ROLE                       VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      PRIMARY_CONTACT_FLAG       VARCHAR2(1)   := 'N',

      /* BUG# 1355914 - FIX START*/
      START_DATE_ACTIVE          DATE          := FND_API.G_MISS_DATE,
      END_DATE_ACTIVE            DATE          := FND_API.G_MISS_DATE,
      /* BUG# 1355914 - FIX END*/

      FULL_ACCESS_FLAG           VARCHAR2(1)   := 'Y',
      ORG_ID                     NUMBER        := FND_API.G_MISS_NUM,
      -- Adding the attribute columns as fix for bug 7168485.
      ATTRIBUTE_CATEGORY          VARCHAR2(30)   := FND_API.G_MISS_CHAR,
      ATTRIBUTE1                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE2                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE3                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE4                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE5                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE6                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE7                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE8                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE9                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE10                 VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE11                 VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE12                 VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE13                 VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE14                 VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE15                 VARCHAR2(150)  := FND_API.G_MISS_CHAR);

  G_MISS_TERRRESOURCE_REC            TerrResource_rec_type;

  TYPE TerrResource_tbl_type         IS TABLE OF   TerrResource_rec_type
                                     INDEX BY BINARY_INTEGER;

  G_MISS_TERRRESOURCE_TBL            TerrResource_tbl_type;


--***********************************************************
-- Start of Comments
-------------------------------------------------------------
-- Territory Resource out Record: TerrResource_out_rec_type
-------------------------------------------------------------
 TYPE TerrResource_out_rec_type     IS RECORD
    (
       TERR_RSC_ID                   NUMBER        := FND_API.G_MISS_NUM,
       RETURN_STATUS                 VARCHAR2(01)  := FND_API.G_MISS_CHAR
    );

  G_MISS_TERRRESOURCE_OUT_REC        TerrResource_out_rec_type;


  TYPE   TerrResource_out_tbl_type   IS TABLE OF   TerrResource_out_rec_type
                                     INDEX BY BINARY_INTEGER;

  G_MISS_TERRRESOURCE_OUT_TBL        TerrResource_out_tbl_type;


---------------------------------------------------------
--  Territory Resource Record: TerrRsc_Access_type
---------------------------------------------------------
 TYPE TerrRsc_Access_Rec_type     IS RECORD
    (
      TERR_RSC_ACCESS_ID           NUMBER        := FND_API.G_MISS_NUM,
      LAST_UPDATE_DATE             DATE          := FND_API.G_MISS_DATE,
      LAST_UPDATED_BY              NUMBER        := FND_API.G_MISS_NUM,
      CREATION_DATE                DATE          := FND_API.G_MISS_DATE,
      CREATED_BY                   NUMBER        := FND_API.G_MISS_NUM,
      LAST_UPDATE_LOGIN            NUMBER        := FND_API.G_MISS_NUM,
      TERR_RSC_ID                  NUMBER        := FND_API.G_MISS_NUM,
      ACCESS_TYPE                  VARCHAR2(30)  := FND_API.G_MISS_CHAR,
      ORG_ID                       NUMBER        := FND_API.G_MISS_NUM,
      QUALIFIER_TBL_INDEX          NUMBER        := FND_API.G_MISS_NUM,
   	  TRANS_ACCESS_CODE			   VARCHAR2(15)  := FND_API.G_MISS_CHAR
    );

  G_MISS_TERRRSC_ACCESS_REC        TerrRsc_Access_Rec_type;

  TYPE TerrRsc_Access_tbl_type     IS TABLE OF   TerrRsc_Access_rec_type
                                   INDEX BY BINARY_INTEGER;

  G_MISS_TERRRSC_ACCESS_TBL        TerrRsc_Access_tbl_type;



-- ***********************************************************
-- Start of Comments
-------------------------------------------------------------------
-- Territory Resource access out Record: TerrResource_out_rec_type
-------------------------------------------------------------------
 TYPE TerrRsc_Access_Out_rec_type     IS RECORD
    (
       TERR_RSC_ACCESS_ID              NUMBER        := FND_API.G_MISS_NUM,
       RETURN_STATUS                   VARCHAR2(01)  := FND_API.G_MISS_CHAR
    );

  G_MISS_TERRRSC_ACCESS_OUT_REC        TerrRsc_Access_Out_rec_type;


  TYPE   TerrRsc_Access_out_tbl_type   IS TABLE OF   TerrRsc_Access_Out_rec_type
                                       INDEX BY BINARY_INTEGER;

  G_MISS_TERRRSC_ACCESS_OUT_TBL        TerrRsc_Access_out_tbl_type;


--    ***************************************************
--    Start of Comments
--    ---------------------------------------------------
--    Territory record type: Terr_All_Rec_Type
--    ---------------------------------------------------
 TYPE Terr_All_Rec_Type          IS RECORD
    (
      TERR_ID                     NUMBER         := FND_API.G_MISS_NUM,
      LAST_UPDATE_DATE            DATE           := FND_API.G_MISS_DATE,
      LAST_UPDATED_BY             NUMBER         := FND_API.G_MISS_NUM,
      CREATION_DATE               DATE           := FND_API.G_MISS_DATE,
      CREATED_BY                  NUMBER         := FND_API.G_MISS_NUM,
      LAST_UPDATE_LOGIN           NUMBER         := FND_API.G_MISS_NUM,
      APPLICATION_SHORT_NAME      VARCHAR2(50)   := FND_API.G_MISS_CHAR,
      NAME                        VARCHAR2(2000) := FND_API.G_MISS_CHAR,
      ENABLED_FLAG                VARCHAR2(1)    := 'N',
      REQUEST_ID                  NUMBER         := FND_API.G_MISS_NUM,
      PROGRAM_APPLICATION_ID      NUMBER         := FND_API.G_MISS_NUM,
      PROGRAM_ID                  NUMBER         := FND_API.G_MISS_NUM,
      PROGRAM_UPDATE_DATE         DATE           := FND_API.G_MISS_DATE,
      START_DATE_ACTIVE           DATE           := FND_API.G_MISS_DATE,
      RANK                        NUMBER         := FND_API.G_MISS_NUM,
      END_DATE_ACTIVE             DATE           := FND_API.G_MISS_DATE,
      DESCRIPTION                 VARCHAR2(240)  := FND_API.G_MISS_CHAR,
      UPDATE_FLAG                 VARCHAR2(1)    := 'Y',
      AUTO_ASSIGN_RESOURCES_FLAG  VARCHAR2(1)    := FND_API.G_MISS_CHAR,
      PLANNED_FLAG                VARCHAR2(1)    := FND_API.G_MISS_CHAR,
      TERRITORY_TYPE_ID           NUMBER         := FND_API.G_MISS_NUM,
      PARENT_TERRITORY_ID         NUMBER         := FND_API.G_MISS_NUM,
      TEMPLATE_FLAG               VARCHAR2(1)    := 'N',
      TEMPLATE_TERRITORY_ID       NUMBER         := FND_API.G_MISS_NUM,
      ESCALATION_TERRITORY_FLAG   VARCHAR2(1)    := 'N',
      ESCALATION_TERRITORY_ID     NUMBER         := FND_API.G_MISS_NUM,
      OVERLAP_ALLOWED_FLAG        VARCHAR2(1)    := FND_API.G_MISS_CHAR,
      ATTRIBUTE_CATEGORY          VARCHAR2(30)   := FND_API.G_MISS_CHAR,
      ATTRIBUTE1                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE2                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE3                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE4                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE5                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE6                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE7                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE8                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE9                  VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE10                 VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE11                 VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE12                 VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE13                 VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE14                 VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE15                 VARCHAR2(150)  := FND_API.G_MISS_CHAR,
      ORG_ID                      NUMBER         := FND_API.G_MISS_NUM,
      NUM_WINNERS                 NUMBER         := FND_API.G_MISS_NUM
    );

  TYPE Terr_All_Tbl_Type          IS TABLE OF Terr_All_Rec_Type
                                  INDEX BY BINARY_INTEGER;

  G_MISS_Terr_All_Rec             Terr_All_Rec_Type;

  G_MISS_Terr_All_Tbl             Terr_All_Tbl_Type;


--    ***************************************************
--    Start of Comments
--    ---------------------------------------------------
 TYPE Terr_Qual_Rec_Type           IS RECORD
    (
      Rowid                         VARCHAR2(50) := FND_API.G_MISS_CHAR,
      TERR_QUAL_ID                  NUMBER       := FND_API.G_MISS_NUM,
      LAST_UPDATE_DATE              DATE         := FND_API.G_MISS_DATE,
      LAST_UPDATED_BY               NUMBER       := FND_API.G_MISS_NUM,
      CREATION_DATE                 DATE         := FND_API.G_MISS_DATE,
      CREATED_BY                    NUMBER       := FND_API.G_MISS_NUM,
      LAST_UPDATE_LOGIN             NUMBER       := FND_API.G_MISS_NUM,
      TERR_ID                       NUMBER       := FND_API.G_MISS_NUM,
      QUAL_USG_ID                   NUMBER       := FND_API.G_MISS_NUM,
      USE_TO_NAME_FLAG              VARCHAR2(1)  := FND_API.G_MISS_CHAR,
      GENERATE_FLAG                 VARCHAR2(1)  := FND_API.G_MISS_CHAR,
      OVERLAP_ALLOWED_FLAG          VARCHAR2(1)  := 'Y',
      QUALIFIER_MODE                VARCHAR2(30) := FND_API.G_MISS_CHAR,
      ORG_ID                        NUMBER       := FND_API.G_MISS_NUM
    );

  TYPE Terr_Qual_Tbl_Type           IS TABLE OF Terr_Qual_Rec_Type
                                    INDEX BY BINARY_INTEGER;

  G_MISS_Terr_Qual_Rec              Terr_Qual_Rec_Type;

  G_MISS_Terr_Qual_Tbl              Terr_Qual_Tbl_Type;



--    ***************************************************
--    Start of Comments
--    ---------------------------------------------------
--    Territory values record type: Terr_Values_Rec_Type
--    ---------------------------------------------------
  TYPE Terr_Values_Rec_Type            IS RECORD
    (
      TERR_VALUE_ID                    NUMBER       := FND_API.G_MISS_NUM,
      LAST_UPDATE_DATE                 DATE         := FND_API.G_MISS_DATE,
      LAST_UPDATED_BY                  NUMBER       := FND_API.G_MISS_NUM,
      CREATION_DATE                    DATE         := FND_API.G_MISS_DATE,
      CREATED_BY                       NUMBER       := FND_API.G_MISS_NUM,
      LAST_UPDATE_LOGIN                NUMBER       := FND_API.G_MISS_NUM,
      TERR_QUAL_ID                     NUMBER       := FND_API.G_MISS_NUM,
      INCLUDE_FLAG                     VARCHAR2(15) := FND_API.G_MISS_CHAR,
      COMPARISON_OPERATOR              VARCHAR2(30) := FND_API.G_MISS_CHAR,
      LOW_VALUE_CHAR                   VARCHAR2(60) := FND_API.G_MISS_CHAR,
      HIGH_VALUE_CHAR                  VARCHAR2(60) := FND_API.G_MISS_CHAR,
      LOW_VALUE_NUMBER                 NUMBER       := FND_API.G_MISS_NUM,
      HIGH_VALUE_NUMBER                NUMBER       := FND_API.G_MISS_NUM,
      VALUE_SET                        NUMBER       := FND_API.G_MISS_NUM,
      INTEREST_TYPE_ID                 NUMBER       := FND_API.G_MISS_NUM,
      PRIMARY_INTEREST_CODE_ID         NUMBER       := FND_API.G_MISS_NUM,
      SECONDARY_INTEREST_CODE_ID       NUMBER       := FND_API.G_MISS_NUM,
      CURRENCY_CODE                    VARCHAR2(15) := FND_API.G_MISS_CHAR,
      ID_USED_FLAG                     VARCHAR2(1)  := FND_API.G_MISS_CHAR,
      LOW_VALUE_CHAR_ID                NUMBER       := FND_API.G_MISS_NUM,
      QUALIFIER_TBL_INDEX              NUMBER       := FND_API.G_MISS_NUM,
      ORG_ID                           NUMBER       := FND_API.G_MISS_NUM,
      CNR_GROUP_ID                     NUMBER       := FND_API.G_MISS_NUM,
      VALUE1_ID                        NUMBER       := FND_API.G_MISS_NUM,
      VALUE2_ID                        NUMBER       := FND_API.G_MISS_NUM,
      VALUE3_ID                        NUMBER       := FND_API.G_MISS_NUM,
      VALUE4_ID                        NUMBER       := FND_API.G_MISS_NUM
    );

  TYPE Terr_Values_Tbl_Type            IS TABLE OF Terr_Values_Rec_Type
                                       INDEX BY BINARY_INTEGER;

  G_MISS_Terr_Values_Rec               Terr_Values_Rec_Type;

  G_MISS_Terr_Values_Tbl               Terr_Values_Tbl_Type;


--    ***************************************************
--    Start of Comments
--    ---------------------------------------------------
--    Territory source Record: terr_Usgs_rec_type
--    ---------------------------------------------------
  TYPE terr_usgs_rec_type      IS RECORD
    (
      TERR_USG_ID              NUMBER    := FND_API.G_MISS_NUM,
      SOURCE_ID                NUMBER    := FND_API.G_MISS_NUM,
      TERR_ID                  NUMBER    := FND_API.G_MISS_NUM,
      LAST_UPDATE_DATE         DATE      := FND_API.G_MISS_DATE,
      LAST_UPDATED_BY          NUMBER    := FND_API.G_MISS_NUM,
      CREATION_DATE            DATE      := FND_API.G_MISS_DATE,
      CREATED_BY               NUMBER    := FND_API.G_MISS_NUM,
      LAST_UPDATE_LOGIN        NUMBER    := FND_API.G_MISS_NUM,
      ORG_ID                   NUMBER    := FND_API.G_MISS_NUM
    );

  G_MISS_TERR_USGS_REC         terr_usgs_rec_type;

  TYPE terr_usgs_tbl_type      IS TABLE OF   terr_usgs_rec_type
                               INDEX BY BINARY_INTEGER;

  G_MISS_TERR_USGS_TBL         terr_usgs_tbl_type;


--    *************************************************************
--    Start of Comments
--    -------------------------------------------------------------
--     Territory qualifier Type Record: TerrQualTypeUsgs_rec_type
--    -------------------------------------------------------------
  TYPE terr_qualtypeusgs_rec_type   IS RECORD
    (
      TERR_QUAL_TYPE_USG_ID         NUMBER    := FND_API.G_MISS_NUM,
      TERR_ID                       NUMBER    := FND_API.G_MISS_NUM,
      QUAL_TYPE_USG_ID              NUMBER    := FND_API.G_MISS_NUM,
      LAST_UPDATE_DATE              DATE      := FND_API.G_MISS_DATE,
      LAST_UPDATED_BY               NUMBER    := FND_API.G_MISS_NUM,
      CREATION_DATE                 DATE      := FND_API.G_MISS_DATE,
      CREATED_BY                    NUMBER    := FND_API.G_MISS_NUM,
      LAST_UPDATE_LOGIN             NUMBER    := FND_API.G_MISS_NUM,
      ORG_ID                        NUMBER    := FND_API.G_MISS_NUM
    );

  G_MISS_TERR_QUALTYPEUSGS_REC      terr_qualtypeusgs_rec_type;

  TYPE terr_qualtypeusgs_tbl_type   IS TABLE OF   terr_qualtypeusgs_rec_type
                                    INDEX BY BINARY_INTEGER;

  G_MISS_TERR_QUALTYPEUSGS_TBL      Terr_QualTypeUsgs_tbl_type;


--    ***********************************************************
--    Start of Comments
--    -----------------------------------------------------------
--     Territory out Record:   terr_all_out_rec
--    -----------------------------------------------------------
TYPE terr_all_out_rec_type   IS RECORD
    (
       TERR_ID                       NUMBER        := FND_API.G_MISS_NUM,
       RETURN_STATUS                 VARCHAR2(01)  := FND_API.G_MISS_CHAR
    );

G_MISS_TERR_ALL_OUT_REC              terr_all_out_rec_type;


TYPE   Terr_All_out_tbl_type         IS TABLE OF   terr_all_out_rec_type
                                     INDEX BY BINARY_INTEGER;

G_MISS_TERR_ALL_OUT_TBL              Terr_All_out_tbl_type;


--    ***********************************************************
--    Start of Comments
--    -----------------------------------------------------------
--     Territory usages out Record:   terr_usgs_out_rec_type
--    -----------------------------------------------------------
TYPE Terr_Usgs_out_rec_type   IS RECORD
    (
       TERR_USG_ID                   NUMBER        := FND_API.G_MISS_NUM,
       RETURN_STATUS                 VARCHAR2(01)  := FND_API.G_MISS_CHAR
    );

G_MISS_TERR_USGS_OUT_REC             terr_usgs_out_rec_type;

TYPE   Terr_Usgs_out_tbl_type        IS TABLE OF   terr_usgs_out_rec_type
                                     INDEX BY BINARY_INTEGER;
G_MISS_TERR_USGS_OUT_TBL             Terr_Usgs_out_tbl_type;


--    ****************************************************************
--    Start of Comments
--    ----------------------------------------------------------------
--     Territory qualifier type out Record: terr_QualTypeUsgs_out_rec
--    ----------------------------------------------------------------
TYPE terr_QualTypeUsgs_out_rec_type   IS RECORD
    (
       TERR_QUAL_TYPE_USG_ID         NUMBER        := FND_API.G_MISS_NUM,
       RETURN_STATUS                 VARCHAR2(01)  := FND_API.G_MISS_CHAR
    );

G_MISS_TERRQUALTYPUSGS_OUT_REC       terr_QualTypeUsgs_out_rec_type;

TYPE Terr_QualTypeUsgs_Out_Tbl_Type  IS TABLE OF   terr_QualTypeUsgs_out_rec_type
                                     INDEX BY BINARY_INTEGER;
G_MISS_TERRQUALTYPUSGS_OUT_TBL       Terr_QualTypeUsgs_Out_Tbl_Type;

--    ***********************************************************
--    Start of Comments
--    -----------------------------------------------------------
--     Territory qualifiers out Record:   terr_Oual_out_rec_Type
--    -----------------------------------------------------------
TYPE Terr_Qual_out_rec_type   IS RECORD
    (
       TERR_QUAL_ID                  NUMBER        := FND_API.G_MISS_NUM,
       RETURN_STATUS                 VARCHAR2(01)  := FND_API.G_MISS_CHAR
    );

G_MISS_TERR_QUAL_OUT_REC             Terr_Qual_out_rec_type;

TYPE   Terr_Qual_out_tbl_type        IS TABLE OF   Terr_Qual_out_rec_type
                                     INDEX BY BINARY_INTEGER;
G_MISS_TERR_QUAL_OUT_TBL             Terr_Qual_Out_tbl_type;


--    ***********************************************************
--    Start of Comments
--    -----------------------------------------------------------
--     Territory values out Record:   terr_values_out_rec_type
--    -----------------------------------------------------------
TYPE Terr_Values_out_rec_type   IS RECORD
    (
       TERR_VALUE_ID                 NUMBER        := FND_API.G_MISS_NUM,
       RETURN_STATUS                 VARCHAR2(01)  := FND_API.G_MISS_CHAR
    );

G_MISS_TERR_VALUES_OUT_REC           terr_values_out_rec_type;


TYPE   Terr_Values_out_tbl_type      IS TABLE OF   terr_values_out_rec_type
                                     INDEX BY BINARY_INTEGER;

G_MISS_TERR_VALUES_OUT_TBL           Terr_Values_out_tbl_type;


--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Territory
--    Type      : PUBLIC
--    Function  : To create Territories - which inludes the creation of following
--                Territory Header, Territory Qualifier, terr Usages,
--                Territory Qualifiers and Territory Qualifier Values.
--                P_terr_values_tbl.QUALIFIER_TBL_INDEX is, associates the values with the Qualifier,
--                the index of qualifier record of the qualifier table.
--                Atleast one qualifier value must be passed, other wise, Qualifier can't be created.
--                This procedure creates the records in the following tables.
--                      JTF_TERR_ALL,
--                      JTF_TERR_USGS_ALL,
--                      JTF_TERR_QTYPE_USGS_ALL,
--                      JTF_TERR_QUAL_ALL,
--                      JTF_TERR_VALUES_ALL.
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_Terr_All_Rec                Terr_All_Rec_Type           := G_Miss_Terr_All_Rec
--      p_Terr_Usgs_Tbl               Terr_Usgs_Tbl_Type          := G_MISS_Terr_Usgs_Tbl
--      p_Terr_Qual_Tbl               Terr_Qual_Tbl_Type          := G_Miss_Terr_Qual_Tbl
--      p_Terr_Values_Tbl             Terr_Values_Tbl_Type        := G_Miss_Terr_Values_Tbl
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                    := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                    := FND_API.G_FALSE
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2(1)
--      x_Msg_Count                   NUMBER
--      x_Msg_Data                    VARCHAR2(2000)
--      x_Terr_Id                     NUMBER
--      x_Terr_Usgs_Out_Tbl           Terr_Usgs_Out_Tbl,
--      x_Terr_QualTypeUsgs_Out_Tbl   Terr_QualTypeUsgs_Out_Tbl,
--      x_Terr_Qual_Out_Tbl           Terr_Qual_Out_Tbl,
--      x_Terr_Values_Out_Tbl         Terr_Values_Out_Tbl
--
--
--    Notes:
--
--
--    End of Comments
--
/*#
 * Use this API to create a territory based on territory header information (name, parent territory, rank, etc.),
 * usage, transaction types, qualifiers and qualifier values.
 * @param p_api_version_number API version number
 * @param p_init_msg_list Initialize message array
 * @param p_commit Commit after processing transaction
 * @param p_terr_all_rec Territory detail information like name, rank, number of winners, parent territory
 * @param p_terr_usgs_tbl Territory usage information:
 * -1001 for Oracle Sales and Telesales,
 * -1002 for Oracle Service,
 * -1003 for Oracle Trade Management,
 * -1004 for Oracle Defect Management,
 * -1500 for Oracle Service Contracts,
 * -1600 for Oracle Collections,
 * and -1700 for Oracle Partner Management
 * @param p_terr_qual_tbl Territory qualifier information like qualifier name
 * @param p_terr_values_tbl Territory qualifier value information like condition, qualifier value
 * @param x_return_status API return status stating success, failure or unexpected error
 * @param x_msg_count Number of error messages recorded during processing
 * @param x_msg_data Contains message text if msg_count=1
 * @param x_terr_id Identifier of the created territory
 * @param x_terr_usgs_out_tbl Territory usage information including the territory usage identifier
 * @param x_terr_qualtypeusgs_out_tbl Territory transaction type information including the territory transaction type identifier
 * @param x_terr_qual_out_tbl Territory qualifier information including the territory qualifier identifiers
 * @param x_terr_values_out_tbl Territory qualifier value information including the territory qualifier value identifiers
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Territory
 */

PROCEDURE Create_Territory
 (p_Api_Version_Number          IN  NUMBER,
  p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
  p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
  x_Return_Status               OUT NOCOPY VARCHAR2,
  x_Msg_Count                   OUT NOCOPY NUMBER,
  x_Msg_Data                    OUT NOCOPY VARCHAR2,
  p_Terr_All_Rec                IN  Terr_All_Rec_Type           := G_Miss_Terr_All_Rec,
  p_Terr_Usgs_Tbl               IN  Terr_Usgs_Tbl_Type          := G_MISS_Terr_Usgs_Tbl,
  --p_Terr_QualTypeUsgs_Tbl       IN  Terr_QualTypeUsgs_Tbl_Type  := G_Miss_Terr_QualTypeUsgs_Tbl,
  p_Terr_Qual_Tbl               IN  Terr_Qual_Tbl_Type          := G_Miss_Terr_Qual_Tbl,
  p_Terr_Values_Tbl             IN  Terr_Values_Tbl_Type        := G_Miss_Terr_Values_Tbl,
  x_Terr_Id                     OUT NOCOPY NUMBER,
  x_Terr_Usgs_Out_Tbl           OUT NOCOPY Terr_Usgs_Out_Tbl_Type,
  x_Terr_QualTypeUsgs_Out_Tbl   OUT NOCOPY Terr_QualTypeUsgs_Out_Tbl_Type,
  x_Terr_Qual_Out_Tbl           OUT NOCOPY Terr_Qual_Out_Tbl_Type,
  x_Terr_Values_Out_Tbl         OUT NOCOPY Terr_Values_Out_Tbl_Type);


--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Delete_Territory
--    Type      : PUBLIC
--    Function  : To delete Territories - which would also delete
--                Territory Header, Territory Qualifier,
--                Territory Qualifier Values and Resources.
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
--     OUT NOCOPY     :
--      Parameter Name             Data Type
--      p_Return_Status            VARCHAR2(1)
--      p_Msg_Count                NUMBER
--      p_Msg_Data                 VARCHAR2(2000)
--
--
--    Notes:
--          Rules for deletion have to be very strict.
--
--    End of Comments
--
PROCEDURE Delete_Territory
 (p_Api_Version_Number      IN NUMBER,
  p_Init_Msg_List           IN VARCHAR2 := FND_API.G_FALSE,
  p_Commit                  IN VARCHAR2 := FND_API.G_FALSE,
  x_Return_Status           OUT NOCOPY VARCHAR2,
  x_Msg_Count               OUT NOCOPY NUMBER,
  x_Msg_Data                OUT NOCOPY VARCHAR2,
  p_Terr_Id                 IN NUMBER);


--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_Territory
--    Type      : PUBLIC
--    Function  : To update existing Territory Header whcich will update
--                the records in JTF_TERR_ALL table.
--                We can't update the territory usage and Territory Qual Types.
--                Updating Qualifier Values can be done with Update_Qualifier_Value procedure.
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_Terr_All_Rec                Terr_All_Rec_Type           := G_Miss_Terr_All_Rec
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                    := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                    := FND_API.G_FALSE
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      p_Return_Status               VARCHAR2(1)
--      p_Msg_Count                   NUMBER
--      p_Msg_Data                    VARCHAR2(2000)
--      p_Terr_All_Out_Rec            Terr_All_Out_Rec
--
--
--    Notes:
--
--
--    End of Comments
--

PROCEDURE Update_Territory
 (p_Api_Version_Number          IN  NUMBER,
  p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
  p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
  x_Return_Status               OUT NOCOPY VARCHAR2,
  x_Msg_Count                   OUT NOCOPY NUMBER,
  x_Msg_Data                    OUT NOCOPY VARCHAR2,
  p_Terr_All_Rec                IN  Terr_All_Rec_Type           := G_Miss_Terr_All_Rec,
 /* Territory Usage and Transaction types cant be updated in R12.
  p_Terr_Usgs_Tbl               IN  Terr_Usgs_Tbl_Type          := G_MISS_Terr_Usgs_Tbl,
  p_Terr_QualTypeUsgs_Tbl       IN  Terr_QualTypeUsgs_Tbl_Type  := G_Miss_Terr_QualTypeUsgs_Tbl,
  p_Terr_Qual_Tbl               IN  Terr_Qual_Tbl_Type          := G_Miss_Terr_Qual_Tbl,
  p_Terr_Values_Tbl             IN  Terr_Values_Tbl_Type        := G_Miss_Terr_Values_Tbl, */
  x_Terr_All_Out_Rec            OUT NOCOPY Terr_All_Out_Rec_Type
 -- x_Terr_Usgs_Out_Tbl           OUT NOCOPY Terr_Usgs_Out_Tbl_Type,
 -- x_Terr_QualTypeUsgs_Out_Tbl   OUT NOCOPY Terr_QualTypeUsgs_Out_Tbl_Type,
 -- x_Terr_Qual_Out_Tbl           OUT NOCOPY Terr_Qual_Out_Tbl_Type,
 -- x_Terr_Values_Out_Tbl         OUT NOCOPY Terr_Values_Out_Tbl_Type
 );


--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Deactivate_Territory
--    Type      : PUBLIC
--    Function  : To deactivate Territories - this API also deactivates
--                any sub-territories of this territory.
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
PROCEDURE Deactivate_Territory
 (p_api_version_number      IN NUMBER,
  p_INit_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
  p_commit                  IN VARCHAR2 := FND_API.G_FALSE,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_msg_count               OUT NOCOPY NUMBER,
  x_msg_data                OUT NOCOPY VARCHAR2,
  p_terr_id                 IN NUMBER);


--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Terr_Qualifier
--    Type      : PUBLIC
--    Function  : To create Territories Qualifier and it's Values.
--                Atleast one qualifier value must be passed, other wise, Qualifier can't be created.
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_Terr_Qual_Rec               Terr_Qual_Rec_Type          := G_Miss_Terr_Qual_Tbl
--      p_Terr_Values_Tbl             Terr_Values_Tbl_Type        := G_Miss_Terr_Values_Tbl
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                    := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                    := FND_API.G_FALSE
--      p_validation_level            NUMBER                      := FND_API.G_VALID_LEVEL_FULL,
--
--     OUT     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2(1)
--      x_Msg_Count                   NUMBER
--      x_Msg_Data                    VARCHAR2(2000)
--      x_Terr_Qual_Out_Rec           Terr_Qual_Out_Rec_Type,
--      x_Terr_Values_Out_Tbl         Terr_Values_Out_Tbl
--
--    End of Comments
--
--
PROCEDURE Create_Terr_qualifier
  (
    p_Api_Version_Number  IN  NUMBER,
    p_Init_Msg_List       IN  VARCHAR2 := FND_API.G_FALSE,
    p_Commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_Return_Status       OUT NOCOPY VARCHAR2,
    x_Msg_Count           OUT NOCOPY NUMBER,
    x_Msg_Data            OUT NOCOPY VARCHAR2,
    P_Terr_Qual_Rec       IN  Terr_Qual_Rec_Type := G_Miss_Terr_Qual_Rec,
    p_Terr_Values_Tbl     IN  Terr_Values_Tbl_Type := G_Miss_Terr_Values_Tbl,
    X_Terr_Qual_Out_Rec   OUT NOCOPY Terr_Qual_Out_Rec_Type,
    x_Terr_Values_Out_Tbl OUT NOCOPY Terr_Values_Out_Tbl_Type
 );


--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Delete_Terr_Qualifier
--    Type      : PUBLIC
--    Function  : To delete Territories Qualifier and its values.
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      P_Terr_Qual_Id             NUMBER
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--      p_Commit                   VARCHAR2                         FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name             Data Type
--      p_Return_Status            VARCHAR2(1)
--      p_Msg_Count                NUMBER
--      p_Msg_Data                 VARCHAR2(2000)
--
--
--    Notes:
--          Rules for deletion have to be very strict.
--
--    End of Comments
--
   PROCEDURE Delete_Terr_Qualifier (
      p_api_version_number   IN       NUMBER,
      p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false,
      p_commit               IN       VARCHAR2 := fnd_api.g_false,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2,
      P_Terr_Qual_Id         IN       NUMBER
   );

--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_Qualifier_Value
--    Type      : PUBLIC
--    Function  : To create Territory Qualifier Values.
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_terr_qual_id                NUMBER (Territory Qualifier ID)
--      p_Terr_Values_Tbl             Terr_Values_Tbl_Type        := G_Miss_Terr_Values_Tbl
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                    := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                    := FND_API.G_FALSE
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      p_Return_Status               VARCHAR2(1)
--      p_Msg_Count                   NUMBER
--      p_Msg_Data                    VARCHAR2(2000)
--      p_Terr_Values_Out_Tbl         Terr_Values_Out_Tbl
--
--    Notes: Custmer need to verify the validity of the Territory Qualifier Value being passed to the procedure.
--    Example : The city name as 'ADDION', instead of ADDISON, is not validated.
--
--    End of Comments
--
 PROCEDURE Create_Qualifier_Value (
      p_api_version_number          IN       NUMBER,
      p_init_msg_list               IN       VARCHAR2 := fnd_api.g_false,
      p_commit                      IN       VARCHAR2 := fnd_api.g_false,
      x_return_status               OUT NOCOPY      VARCHAR2,
      x_msg_count                   OUT NOCOPY      NUMBER,
      x_msg_data                    OUT NOCOPY      VARCHAR2,
      p_terr_qual_id                IN  NUMBER,
      p_terr_values_tbl             IN       terr_values_tbl_type
            := g_miss_terr_values_tbl,
      x_terr_values_out_tbl         OUT NOCOPY      terr_values_out_tbl_type
   );
 --    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_Terr_Value
--    Type      : PUBLIC
--    Function  : To update existing Territory Qualifier Values
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_Terr_Values_Tbl             Terr_Values_Tbl_Type        := G_Miss_Terr_Values_Tbl
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                    := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                    := FND_API.G_FALSE
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      p_Return_Status               VARCHAR2(1)
--      p_Msg_Count                   NUMBER
--      p_Msg_Data                    VARCHAR2(2000)
--      p_Terr_Values_Out_Tbl         Terr_Values_Out_Tbl
--
--    Notes: Custmoer need to verify the validity of the Territory Qualifier Value being passed to the procedure.
--    Example : The city name as 'ADDISON', instead of ADDISION, is not validated.
--
--    End of Comments
--
 PROCEDURE Update_Qualifier_Value (
      p_api_version_number          IN       NUMBER,
      p_init_msg_list               IN       VARCHAR2 := fnd_api.g_false,
      p_commit                      IN       VARCHAR2 := fnd_api.g_false,
      x_return_status               OUT NOCOPY      VARCHAR2,
      x_msg_count                   OUT NOCOPY      NUMBER,
      x_msg_data                    OUT NOCOPY      VARCHAR2,
      p_terr_values_tbl             IN       terr_values_tbl_type
            := g_miss_terr_values_tbl,
      x_terr_values_out_tbl         OUT NOCOPY      terr_values_out_tbl_type
   );

--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Delete_Qualifier_Value
--    Type      : PUBLIC
--    Function  : To delete a Territoriy Qualifier Value
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      P_Terr_Value_Id             NUMBER
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--      p_Commit                   VARCHAR2                         FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name             Data Type
--      p_Return_Status            VARCHAR2(1)
--      p_Msg_Count                NUMBER
--      p_Msg_Data                 VARCHAR2(2000)
--
--
--    Notes:
--          Rules for deletion have to be very strict.
--
--    End of Comments
--
   PROCEDURE Delete_Qualifier_Value (
      p_api_version_number   IN       NUMBER,
      p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false,
      p_commit               IN       VARCHAR2 := fnd_api.g_false,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2,
      P_Terr_Value_Id         IN       NUMBER
   );


--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Create_TerrResource
--    Type      : PUBLIC
--    Function  : To create Territory Resources - which will insert
--                records into jtf_terr_rsc_access_all, jtf_terr_rsc_all
--                tables.
--                If the user doesnot provide resource access records, this procedure
--                inserts the rows into jtf_terr_rsc_access_all for all Transaction Types
--                associated with the territory with access as 'FULL_ACCESS'.
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_TerrRsc_Tbl                 TerrResource_tbl_type            := G_MISS_TERRRESOURCE_TBL
--      p_TerrRsc_Access_Tbl          TerrRsc_Access_tbl_type          := G_MISS_TERRRSC_ACCESS_TBL
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                         := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                         := FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2(1)
--      x_Msg_Count                   NUMBER
--      x_Msg_Data                    VARCHAR2(2000)
--      x_TerrRsc_Id                  NUMBER
--      x_TerrRsc_Out_Tbl             TerrResource_out_tbl_type,
--      x_TerrRsc_Access_Out_Tbl      TerrRsc_Access_out_tbl_type);
--
--    Notes:
--
--
--    End of Comments
--

/*#
 * Use this API to assign resources and their access information to a territory.
 * @param p_api_version_number API version number
 * @param p_init_msg_list Initialize message array
 * @param p_commit Commit after processing transaction
 * @param p_terrrsc_tbl Territory resource information like resource, resource group and/or resource role
 * @param p_terrrsc_access_tbl Territory resource access information (for example, lead, opportunity, service request)
 * @param x_return_status API return status stating success, failure or unexpected error
 * @param x_msg_count Number of error messages recorded during processing
 * @param x_msg_data Contains message text if msg_count=1
 * @param x_terrrsc_out_tbl Territory resource information including the territory resource identifiers
 * @param x_terrrsc_access_out_tbl Territory resource access information including the territory resource access identifiers
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Assign Resources to a Territory
 */

PROCEDURE Create_TerrResource
  (p_Api_Version_Number          IN  NUMBER,
   p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
   p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_Msg_Count                   OUT NOCOPY NUMBER,
   x_Msg_Data                    OUT NOCOPY VARCHAR2,
   p_TerrRsc_Tbl                 IN  TerrResource_tbl_type       := G_MISS_TERRRESOURCE_TBL,
   p_TerrRsc_Access_Tbl          IN  TerrRsc_Access_tbl_type     := G_MISS_TERRRSC_ACCESS_TBL,
   x_TerrRsc_Out_Tbl             OUT NOCOPY TerrResource_out_tbl_type,
   x_TerrRsc_Access_Out_Tbl      OUT NOCOPY TerrRsc_Access_out_tbl_type);

--    ***************************************************
--    start of comments
--    ***************************************************
--
--    API name  : Delete_TerrResource
--    Type      : PUBLIC
--    Function  : To delete Territories - which would also delete
--                records from jtf_terr_rsc_access_all, jtf_terr_rsc_all
--                tables.
--
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name             Data Type                        Default
--      p_Api_Version_Number       NUMBER
--      p_TerrRsc_Id               NUMBER
--
--      Optional
--      Parameter Name             Data Type                        Default
--      p_Init_Msg_List            VARCHAR2                         FND_API.G_FALSE
--      p_Commit                   VARCHAR2                         FND_API.G_FALSE
--
--     OUT     :
--      Parameter Name             Data Type
--      p_Return_Status            VARCHAR2(1)
--      p_Msg_Count                NUMBER
--      p_Msg_Data                 VARCHAR2(2000)
--
--
--    Notes:
--          Rules for deletion have to be very strict.
--
--    End of Comments
--
PROCEDURE Delete_TerrResource
 (p_Api_Version_Number      IN  NUMBER,
  p_Init_Msg_List           IN  VARCHAR2 := FND_API.G_FALSE,
  p_Commit                  IN  VARCHAR2 := FND_API.G_FALSE,
  x_Return_Status           OUT NOCOPY VARCHAR2,
  x_Msg_Count               OUT NOCOPY NUMBER,
  x_Msg_Data                OUT NOCOPY VARCHAR2,
  p_TerrRsc_Id              IN  NUMBER);

--    ***************************************************
--    start of comments
--    ***************************************************
--    API name  : Update_TerrResource
--    Type      : PUBLIC
--    Function  : To Update Territory Resources - which will update
--                records into jtf_terr_rsc_access_all, jtf_terr_rsc_all
--                tables.
--    Pre-reqs  :
--    Parameters:
--     IN       :
--      Required
--      Parameter Name                Data Type                        Default
--      p_Api_Version_Number          NUMBER
--      p_TerrRsc_Tbl                 TerrResource_tbl_type            := G_MISS_TERRRESOURCE_TBL
--      p_TerrRsc_Access_Tbl          TerrRsc_Access_tbl_type          := G_MISS_TERRRSC_ACCESS_TBL
--
--      Optional
--      Parameter Name                Data Type  Default
--      p_Init_Msg_List               VARCHAR2                         := FND_API.G_FALSE
--      p_Commit                      VARCHAR2                         := FND_API.G_FALSE
--
--     OUT NOCOPY     :
--      Parameter Name                Data Type
--      x_Return_Status               VARCHAR2(1)
--      x_Msg_Count                   NUMBER
--      x_Msg_Data                    VARCHAR2(2000)
--      x_TerrRsc_Id                  NUMBER
--      x_TerrRsc_Out_Tbl             TerrResource_out_tbl_type,
--      x_TerrRsc_Access_Out_Tbl      TerrRsc_Access_out_tbl_type
--
--    Notes:
--
--
--    End of Comments
--
PROCEDURE Update_TerrResource
  (p_Api_Version_Number          IN  NUMBER,
   p_Init_Msg_List               IN  VARCHAR2                    := FND_API.G_FALSE,
   p_Commit                      IN  VARCHAR2                    := FND_API.G_FALSE,
   x_Return_Status               OUT NOCOPY VARCHAR2,
   x_Msg_Count                   OUT NOCOPY NUMBER,
   x_Msg_Data                    OUT NOCOPY VARCHAR2,
   p_TerrRsc_Tbl                 IN  TerrResource_tbl_type       := G_MISS_TERRRESOURCE_TBL,
   p_TerrRsc_Access_Tbl          IN  TerrRsc_Access_tbl_type     := G_MISS_TERRRSC_ACCESS_TBL,
   x_TerrRsc_Out_Tbl             OUT NOCOPY TerrResource_out_tbl_type,
   x_TerrRsc_Access_Out_Tbl      OUT NOCOPY TerrRsc_Access_out_tbl_type);


/* THE FOLLOWING 3 RECORD SPECS SHOULD NO LONGER BE USED: THEY
   ARE LISTED HERE FOR BACKWARD COMPATIBILITY
*/
---------------------------------------------------------
--               Account record format
--    ---------------------------------------------------
--    Parameters:
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments

TYPE JTF_Account_rec_type       IS RECORD
(
      CITY                          VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      POSTAL_CODE                   VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      STATE                         VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      PROVINCE                      VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      COUNTY                        VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      COUNTRY                       VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      INTEREST_TYPE_ID              NUMBER        := FND_API.G_MISS_NUM,
      PRIMARY_INTEREST_ID           NUMBER        := FND_API.G_MISS_NUM,
      SECONDARY_INTEREST_ID         NUMBER        := FND_API.G_MISS_NUM,
      CONTACT_INTEREST_TYPE_ID      NUMBER        := FND_API.G_MISS_NUM,
      CONTACT_PRIMARY_INTEREST_ID   NUMBER        := FND_API.G_MISS_NUM,
      CONTACT_SECONDARY_INTEREST_ID NUMBER        := FND_API.G_MISS_NUM,
      PARTY_SITE_ID                 NUMBER        := FND_API.G_MISS_NUM,
      AREA_CODE                     VARCHAR2(10)  := FND_API.G_MISS_CHAR,
      PARTY_ID                      NUMBER        := FND_API.G_MISS_NUM,
      COMP_NAME_RANGE               VARCHAR2(360) := FND_API.G_MISS_CHAR,
      PARTNER_ID                    NUMBER        := FND_API.G_MISS_NUM,
      NUM_OF_EMPLOYEES              NUMBER        := FND_API.G_MISS_NUM,
      CATEGORY_CODE                 VARCHAR2(30)  := FND_API.G_MISS_CHAR,
      PARTY_RELATIONSHIP_ID         NUMBER        := FND_API.G_MISS_NUM,
      SIC_CODE                      VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      ATTRIBUTE1                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE2                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE3                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE4                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE5                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE6                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE7                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE8                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE9                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE10                   VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE11                   VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE12                   VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE13                   VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE14                   VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE15                   VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ORG_ID                        NUMBER        := FND_PROFILE.VALUE('ORG_ID')
);

---------------------------------------------------------
--               Opportunity record format
--    ---------------------------------------------------
--    Parameters:
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments


TYPE JTF_Oppor_rec_type        IS RECORD
(     LEAD_ID                        NUMBER        := FND_API.G_MISS_NUM,
      LEAD_LINE_ID                   NUMBER        := FND_API.G_MISS_NUM,
      CITY                           VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      POSTAL_CODE                    VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      STATE                          VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      PROVINCE                       VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      COUNTY                         VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      COUNTRY                        VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      INTEREST_TYPE_ID               NUMBER        := FND_API.G_MISS_NUM,
      PRIMARY_INTEREST_ID            NUMBER        := FND_API.G_MISS_NUM,
      SECONDARY_INTEREST_ID          NUMBER        := FND_API.G_MISS_NUM,
      CONTACT_INTEREST_TYPE_ID       NUMBER        := FND_API.G_MISS_NUM,
      CONTACT_PRIMARY_INTEREST_ID    NUMBER        := FND_API.G_MISS_NUM,
      CONTACT_SECONDARY_INTEREST_ID  NUMBER        := FND_API.G_MISS_NUM,
      PARTY_SITE_ID                  NUMBER        := FND_API.G_MISS_NUM,
      AREA_CODE                      VARCHAR2(10)  := FND_API.G_MISS_CHAR,
      PARTY_ID                       NUMBER        := FND_API.G_MISS_NUM,
      COMP_NAME_RANGE                VARCHAR2(360) := FND_API.G_MISS_CHAR,
      PARTNER_ID                     NUMBER        := FND_API.G_MISS_NUM,
      NUM_OF_EMPLOYEES               NUMBER        := FND_API.G_MISS_NUM,
      CATEGORY_CODE                  VARCHAR2(30)  := FND_API.G_MISS_CHAR,
      PARTY_RELATIONSHIP_ID          NUMBER        := FND_API.G_MISS_NUM,
      SIC_CODE                       VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      TARGET_SEGMENT_CURRENT         VARCHAR2(25)  := FND_API.G_MISS_CHAR,
      TOTAL_AMOUNT                   NUMBER        := FND_API.G_MISS_NUM,
      CURRENCY_CODE                  VARCHAR2(15)  := FND_API.G_MISS_CHAR,
      PRICING_DATE                   DATE          := FND_API.G_MISS_DATE,
      CHANNEL_CODE                   VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      INVENTORY_ITEM_ID              NUMBER        := FND_API.G_MISS_NUM,
      OPP_INTEREST_TYPE_ID           NUMBER        := FND_API.G_MISS_NUM,
      OPP_PRIMARY_INTEREST_ID        NUMBER        := FND_API.G_MISS_NUM,
      OPP_SECONDARY_INTEREST_ID      NUMBER        := FND_API.G_MISS_NUM,
      OPCLSS_INTEREST_TYPE_ID        NUMBER        := FND_API.G_MISS_NUM,
      OPCLSS_PRIMARY_INTEREST_ID     NUMBER        := FND_API.G_MISS_NUM,
      OPCLSS_SECONDARY_INTEREST_ID   NUMBER        := FND_API.G_MISS_NUM,
      ATTRIBUTE1                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE2                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE3                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE4                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE5                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE6                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE7                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE8                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE9                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE10                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE11                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE12                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE13                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE14                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE15                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ORG_ID                         NUMBER        := FND_PROFILE.VALUE('ORG_ID')
);


---------------------------------------------------------
--               Lead record format
--    ---------------------------------------------------
--    Parameters:
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments


TYPE JTF_Lead_rec_type        IS RECORD
(
      SALES_LEAD_ID                  NUMBER        := FND_API.G_MISS_NUM,
      SALES_LEAD_LINE_ID             NUMBER        := FND_API.G_MISS_NUM,
      CITY                           VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      POSTAL_CODE                    VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      STATE                          VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      PROVINCE                       VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      COUNTY                         VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      COUNTRY                        VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      INTEREST_TYPE_ID               NUMBER        := FND_API.G_MISS_NUM,
      PRIMARY_INTEREST_ID            NUMBER        := FND_API.G_MISS_NUM,
      SECONDARY_INTEREST_ID          NUMBER        := FND_API.G_MISS_NUM,
      CONTACT_INTEREST_TYPE_ID       NUMBER        := FND_API.G_MISS_NUM,
      CONTACT_PRIMARY_INTEREST_ID    NUMBER        := FND_API.G_MISS_NUM,
      CONTACT_SECONDARY_INTEREST_ID  NUMBER        := FND_API.G_MISS_NUM,
      PARTY_SITE_ID                  NUMBER        := FND_API.G_MISS_NUM,
      AREA_CODE                      VARCHAR2(10)  := FND_API.G_MISS_CHAR,
      PARTY_ID                       NUMBER        := FND_API.G_MISS_NUM,
      COMP_NAME_RANGE                VARCHAR2(360) := FND_API.G_MISS_CHAR,
      PARTNER_ID                     NUMBER        := FND_API.G_MISS_NUM,
      NUM_OF_EMPLOYEES               NUMBER        := FND_API.G_MISS_NUM,
      CATEGORY_CODE                  VARCHAR2(30)  := FND_API.G_MISS_CHAR,
      PARTY_RELATIONSHIP_ID          NUMBER        := FND_API.G_MISS_NUM,
      SIC_CODE                       VARCHAR2(60)  := FND_API.G_MISS_CHAR,
      BUDGET_AMOUNT                  NUMBER        := FND_API.G_MISS_NUM,
      CURRENCY_CODE                  VARCHAR2(15)  := FND_API.G_MISS_CHAR,
      PRICING_DATE                   DATE          := FND_API.G_MISS_DATE,
      SOURCE_PROMOTION_ID            NUMBER        := FND_API.G_MISS_NUM,
      INVENTORY_ITEM_ID              NUMBER        := FND_API.G_MISS_NUM,
      LEAD_INTEREST_TYPE_ID          NUMBER        := FND_API.G_MISS_NUM,
      LEAD_PRIMARY_INTEREST_ID       NUMBER        := FND_API.G_MISS_NUM,
      LEAD_SECONDARY_INTEREST_ID     NUMBER        := FND_API.G_MISS_NUM,
      PURCHASE_AMOUNT                NUMBER        := FND_API.G_MISS_NUM,
      ATTRIBUTE1                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE2                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE3                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE4                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE5                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE6                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE7                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE8                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE9                     VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE10                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE11                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE12                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE13                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE14                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ATTRIBUTE15                    VARCHAR2(150) := FND_API.G_MISS_CHAR,
      ORG_ID                         NUMBER        := FND_PROFILE.VALUE('ORG_ID')
);


--
END JTF_TERRITORY_PUB;

/
