--------------------------------------------------------
--  DDL for Package Body JTF_TERR_ASSIGN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_ASSIGN_PUB" AS
/* $Header: jtfptrwb.pls 120.7 2006/03/30 17:15:37 achanda ship $ */
---------------------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_ASSIGN_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force applications territory manager public api's.
--      This package is a public API for getting winning territories
--      or territory resources.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--      Valid values for USE_TYPE:
--          TERRITORY - return only the distinct winning territories
--          RESOURCE  - return resources of all winning territories
--          LOOKUP    - return resource information as needed in territory Lookup
--
--          Program Flow:
--              Check usage to call proper API.
--                  set output to lx_win_rec
--              Process lx_win_rec for output depending on USE_TYPE
--
--      Terminology:    ---------------------------------------------------------
--
--          jtf_account_bulk_rec_type, jtf_lead_bulk_rec_type - known as
--          TRANSACTION-BASED input types, since they are different for each transaction, bulk or not.
--
--          jtf_terr_assign.bulk_gen_trans_rec_type - known as
--          GENERIC-TRANSACTION bulk input type, since it handles all transaction assignment requests.
--
--          Variable Names
--              bulk_winners_rec_type may have several uses depending on use_type
--              The names of these variables to be used will be as follows:
--                  use_type        variable Name
--                  -----------------------------------
--                  RESOURCE        <not needed - simply copy dyn ouput to API output>
--                  TERRITORY       lx_terr_win_rec
--                  LOOKUP          lx_lookup_bulk_winners_rec
--
--
--    HISTORY
--      06/21/2001  EIHSU       CREATED
--      07/12/01    jdochert    creating additional parameters
--      07/17/2001  EIHSU       Add logic control for formatting different
--                              outputs based on USE_TYPE
--      07/19/2001  EIHSU       Sales/Account:
--                              Convert generic bulk type to transaction-based bulk type
--                              to call sales/account dyn; and converts
--                              output to gen output type (this until dyn packages are changed)
--      07/23/2001  EIHSU       TERRITORY use type code completed for distinct terr_id output
--      07/23/2001  EIHSU       Usage logic and use_type output logic separated
--                              (see "Program Flow" above.)
--      07/24/2001  arpatel     Added call to JTF_TERR_1003_CLAIM_DYN for Trade Management/Claim
--      10/01/2001  arpatel     Now convert bulk_gen_trans_rec_type to specific transaction bulk type
--                              for Sales and Telesales/Account and for all use_types
--      01/22/2002  eihsu       Fix bug 2185024
--      02/05/2002  eihsu       Fix bugs 2212655 2185024
--      02/14/02    sp          Added call to JTF_TERR_1500_KREN_DYN for Contracts for bug 2220941
--      10/11/2002  jradhakr    Added call to JTF_TERR_1600_DELQCY_DYN for including Collections qualifiers
--                              bug 1677560
--      04/28/2004  achanda     bug 3562041 : remove the outer join to hz_parties
--      05/26/2005  achanda     modified to the new 12.0 architecture
--    End of Comments

-- ***************************************************
--    GLOBAL VARIABLES and RECORD TYPE DEFINITIONS
-- ***************************************************

   G_PKG_NAME      CONSTANT VARCHAR2(30):='JTF_TERR_ASSIGN_PUB';
   G_FILE_NAME     CONSTANT VARCHAR2(12):='jtfptrwb.pls';

   G_NEW_LINE        VARCHAR2(02) := fnd_global.local_chr(10);
   G_APPL_ID         NUMBER       := FND_GLOBAL.Prog_Appl_Id;
   G_LOGIN_ID        NUMBER       := FND_GLOBAL.Conc_Login_Id;
   G_PROGRAM_ID      NUMBER       := FND_GLOBAL.Conc_Program_Id;
   G_USER_ID         NUMBER       := FND_GLOBAL.User_Id;
   G_REQUEST_ID      NUMBER       := FND_GLOBAL.Conc_Request_Id;
   G_APP_SHORT_NAME  VARCHAR2(15) := FND_GLOBAL.Application_Short_Name;

--    ***************************************************
--    API Body Definitions
--    ***************************************************
PROCEDURE get_winners
(   p_api_version_number    IN          NUMBER,
    p_init_msg_list         IN          VARCHAR2  := FND_API.G_FALSE,
    p_use_type              IN          VARCHAR2 := 'RESOURCE',
    p_source_id             IN          NUMBER,
    p_trans_id              IN          NUMBER,
    p_trans_rec             IN          bulk_trans_rec_type,
    p_resource_type         IN          VARCHAR2 := FND_API.G_MISS_CHAR,
    p_role                  IN          VARCHAR2 := FND_API.G_MISS_CHAR,
    p_top_level_terr_id     IN          NUMBER   := FND_API.G_MISS_NUM,
    p_num_winners           IN          NUMBER   := FND_API.G_MISS_NUM,
    x_return_status         OUT NOCOPY         VARCHAR2,
    x_msg_count             OUT NOCOPY         NUMBER,
    x_msg_data              OUT NOCOPY         VARCHAR2,
    x_winners_rec           OUT NOCOPY  bulk_winners_rec_type
)
AS

  l_api_name                   CONSTANT VARCHAR2(30) := 'Get_Winners';
  l_api_version_number         CONSTANT NUMBER       := 1.0;
  l_count1                     NUMBER;
  l_num_of_terr                NUMBER;
  l_Counter                    NUMBER;

  l_program_name               VARCHAR2(60);
  l_sysdate                    DATE;

  l_role                       VARCHAR2(60);
  l_resource_type              VARCHAR2(60);

  lx_winners_rec   JTY_ASSIGN_REALTIME_PUB.bulk_winners_rec_type;

BEGIN

  -- debug message
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jtf_terr_assign_pub.get_winners.begin',
                   'Start of the procedure jtf_terr_assign_pub.get_winners');
  END IF;

  -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME)  THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  ------------------
  -- API body
  ------------------
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_sysdate       := SYSDATE;
  l_count1      := 0;
  l_num_of_terr := 0;
  l_counter     := 0;
  IF (p_role = FND_API.G_MISS_CHAR) THEN
    l_role := null;
  ELSE
    l_role := p_role;
  END IF;
  IF (p_resource_type = FND_API.G_MISS_CHAR) THEN
    l_resource_type := null;
  ELSE
    l_resource_type := p_resource_type;
  END IF;

  /* Check for territories for this Usage/Transaction Type */
  BEGIN

    /* ARPATEL: Sales records are no longer striped by tx type */
    if p_source_id = -1001 then
	  SELECT COUNT(*)
      INTO l_num_of_terr
      FROM jtf_terr_denorm_rules_all jtdr
      WHERE jtdr.source_id = p_source_id
      AND rownum < 2;
	else
      SELECT COUNT(*)
      INTO l_num_of_terr
      FROM jtf_terr_denorm_rules_all jtdr
      WHERE jtdr.source_id = p_source_id
      AND rownum < 2;
    end if;

  EXCEPTION
    WHEN NO_DATA_FOUND Then
      l_num_of_terr := 0;
  END;

  /* Only call assignment APIs if valid territories exist */
  IF ( l_num_of_terr > 0 ) THEN

    /* Trade Management/Offer */
    IF ( p_source_id = -1003 AND p_trans_id = -1007) THEN
      l_program_name := 'TRADE MANAGEMENT/OFFER PROGRAM';
      DELETE jty_terr_1003_offer_trans_gt;

      FORALL i IN p_trans_rec.trans_object_id.FIRST .. p_trans_rec.trans_object_id.LAST
        INSERT INTO jty_terr_1003_offer_trans_gt (
          use_type
          ,source_id
          ,transaction_id
          ,trans_object_id
          ,trans_detail_object_id
          ,SQUAL_CHAR01
          ,SQUAL_CHAR02
          ,SQUAL_CHAR03
          ,SQUAL_CHAR04
          ,SQUAL_CHAR05
          ,SQUAL_CHAR06
          ,SQUAL_CHAR07
          ,SQUAL_CHAR08
          ,SQUAL_CHAR09
          ,SQUAL_CHAR10
          ,SQUAL_CHAR11
          ,SQUAL_CHAR12
          ,SQUAL_CHAR13
          ,SQUAL_CHAR14
          ,SQUAL_CHAR15
          ,SQUAL_CHAR16
          ,SQUAL_CHAR17
          ,SQUAL_CHAR18
          ,SQUAL_CHAR19
          ,SQUAL_CHAR20
          ,SQUAL_CHAR21
          ,SQUAL_CHAR22
          ,SQUAL_CHAR23
          ,SQUAL_CHAR24
          ,SQUAL_CHAR25
          ,SQUAL_CHAR26
          ,SQUAL_CHAR27
          ,SQUAL_CHAR28
          ,SQUAL_CHAR29
          ,SQUAL_CHAR30
          ,SQUAL_CHAR31
          ,SQUAL_CHAR32
          ,SQUAL_CHAR33
          ,SQUAL_CHAR34
          ,SQUAL_CHAR35
          ,SQUAL_CHAR36
          ,SQUAL_CHAR37
          ,SQUAL_CHAR38
          ,SQUAL_CHAR39
          ,SQUAL_CHAR40
          ,SQUAL_CHAR41
          ,SQUAL_CHAR42
          ,SQUAL_CHAR43
          ,SQUAL_CHAR44
          ,SQUAL_CHAR45
          ,SQUAL_CHAR46
          ,SQUAL_CHAR47
          ,SQUAL_CHAR48
          ,SQUAL_CHAR49
          ,SQUAL_CHAR50
          ,SQUAL_NUM01
          ,SQUAL_NUM02
          ,SQUAL_NUM03
          ,SQUAL_NUM04
          ,SQUAL_NUM05
          ,SQUAL_NUM06
          ,SQUAL_NUM07
          ,SQUAL_NUM08
          ,SQUAL_NUM09
          ,SQUAL_NUM10
          ,SQUAL_NUM11
          ,SQUAL_NUM12
          ,SQUAL_NUM13
          ,SQUAL_NUM14
          ,SQUAL_NUM15
          ,SQUAL_NUM16
          ,SQUAL_NUM17
          ,SQUAL_NUM18
          ,SQUAL_NUM19
          ,SQUAL_NUM20
          ,SQUAL_NUM21
          ,SQUAL_NUM22
          ,SQUAL_NUM23
          ,SQUAL_NUM24
          ,SQUAL_NUM25
          ,SQUAL_NUM26
          ,SQUAL_NUM27
          ,SQUAL_NUM28
          ,SQUAL_NUM29
          ,SQUAL_NUM30
          ,SQUAL_NUM31
          ,SQUAL_NUM32
          ,SQUAL_NUM33
          ,SQUAL_NUM34
          ,SQUAL_NUM35
          ,SQUAL_NUM36
          ,SQUAL_NUM37
          ,SQUAL_NUM38
          ,SQUAL_NUM39
          ,SQUAL_NUM40
          ,SQUAL_NUM41
          ,SQUAL_NUM42
          ,SQUAL_NUM43
          ,SQUAL_NUM44
          ,SQUAL_NUM45
          ,SQUAL_NUM46
          ,SQUAL_NUM47
          ,SQUAL_NUM48
          ,SQUAL_NUM49
          ,SQUAL_NUM50
          ,txn_date
        )
        VALUES (
           p_use_type
          ,p_source_id
          ,p_trans_id
          ,p_trans_rec.trans_object_id(i)
          ,p_trans_rec.trans_detail_object_id(i)
          ,p_trans_rec.SQUAL_CHAR01(i)
          ,p_trans_rec.SQUAL_CHAR02(i)
          ,p_trans_rec.SQUAL_CHAR03(i)
          ,p_trans_rec.SQUAL_CHAR04(i)
          ,p_trans_rec.SQUAL_CHAR05(i)
          ,p_trans_rec.SQUAL_CHAR06(i)
          ,p_trans_rec.SQUAL_CHAR07(i)
          ,p_trans_rec.SQUAL_CHAR08(i)
          ,p_trans_rec.SQUAL_CHAR09(i)
          ,p_trans_rec.SQUAL_CHAR10(i)
          ,p_trans_rec.SQUAL_CHAR11(i)
          ,p_trans_rec.SQUAL_CHAR12(i)
          ,p_trans_rec.SQUAL_CHAR13(i)
          ,p_trans_rec.SQUAL_CHAR14(i)
          ,p_trans_rec.SQUAL_CHAR15(i)
          ,p_trans_rec.SQUAL_CHAR16(i)
          ,p_trans_rec.SQUAL_CHAR17(i)
          ,p_trans_rec.SQUAL_CHAR18(i)
          ,p_trans_rec.SQUAL_CHAR19(i)
          ,p_trans_rec.SQUAL_CHAR20(i)
          ,p_trans_rec.SQUAL_CHAR21(i)
          ,p_trans_rec.SQUAL_CHAR22(i)
          ,p_trans_rec.SQUAL_CHAR23(i)
          ,p_trans_rec.SQUAL_CHAR24(i)
          ,p_trans_rec.SQUAL_CHAR25(i)
          ,p_trans_rec.SQUAL_CHAR26(i)
          ,p_trans_rec.SQUAL_CHAR27(i)
          ,p_trans_rec.SQUAL_CHAR28(i)
          ,p_trans_rec.SQUAL_CHAR29(i)
          ,p_trans_rec.SQUAL_CHAR30(i)
          ,p_trans_rec.SQUAL_CHAR31(i)
          ,p_trans_rec.SQUAL_CHAR32(i)
          ,p_trans_rec.SQUAL_CHAR33(i)
          ,p_trans_rec.SQUAL_CHAR34(i)
          ,p_trans_rec.SQUAL_CHAR35(i)
          ,p_trans_rec.SQUAL_CHAR36(i)
          ,p_trans_rec.SQUAL_CHAR37(i)
          ,p_trans_rec.SQUAL_CHAR38(i)
          ,p_trans_rec.SQUAL_CHAR39(i)
          ,p_trans_rec.SQUAL_CHAR40(i)
          ,p_trans_rec.SQUAL_CHAR41(i)
          ,p_trans_rec.SQUAL_CHAR42(i)
          ,p_trans_rec.SQUAL_CHAR43(i)
          ,p_trans_rec.SQUAL_CHAR44(i)
          ,p_trans_rec.SQUAL_CHAR45(i)
          ,p_trans_rec.SQUAL_CHAR46(i)
          ,p_trans_rec.SQUAL_CHAR47(i)
          ,p_trans_rec.SQUAL_CHAR48(i)
          ,p_trans_rec.SQUAL_CHAR49(i)
          ,p_trans_rec.SQUAL_CHAR50(i)
          ,p_trans_rec.SQUAL_NUM01(i)
          ,p_trans_rec.SQUAL_NUM02(i)
          ,p_trans_rec.SQUAL_NUM03(i)
          ,p_trans_rec.SQUAL_NUM04(i)
          ,p_trans_rec.SQUAL_NUM05(i)
          ,p_trans_rec.SQUAL_NUM06(i)
          ,p_trans_rec.SQUAL_NUM07(i)
          ,p_trans_rec.SQUAL_NUM08(i)
          ,p_trans_rec.SQUAL_NUM09(i)
          ,p_trans_rec.SQUAL_NUM10(i)
          ,p_trans_rec.SQUAL_NUM11(i)
          ,p_trans_rec.SQUAL_NUM12(i)
          ,p_trans_rec.SQUAL_NUM13(i)
          ,p_trans_rec.SQUAL_NUM14(i)
          ,p_trans_rec.SQUAL_NUM15(i)
          ,p_trans_rec.SQUAL_NUM16(i)
          ,p_trans_rec.SQUAL_NUM17(i)
          ,p_trans_rec.SQUAL_NUM18(i)
          ,p_trans_rec.SQUAL_NUM19(i)
          ,p_trans_rec.SQUAL_NUM20(i)
          ,p_trans_rec.SQUAL_NUM21(i)
          ,p_trans_rec.SQUAL_NUM22(i)
          ,p_trans_rec.SQUAL_NUM23(i)
          ,p_trans_rec.SQUAL_NUM24(i)
          ,p_trans_rec.SQUAL_NUM25(i)
          ,p_trans_rec.SQUAL_NUM26(i)
          ,p_trans_rec.SQUAL_NUM27(i)
          ,p_trans_rec.SQUAL_NUM28(i)
          ,p_trans_rec.SQUAL_NUM29(i)
          ,p_trans_rec.SQUAL_NUM30(i)
          ,p_trans_rec.SQUAL_NUM31(i)
          ,p_trans_rec.SQUAL_NUM32(i)
          ,p_trans_rec.SQUAL_NUM33(i)
          ,p_trans_rec.SQUAL_NUM34(i)
          ,p_trans_rec.SQUAL_NUM35(i)
          ,p_trans_rec.SQUAL_NUM36(i)
          ,p_trans_rec.SQUAL_NUM37(i)
          ,p_trans_rec.SQUAL_NUM38(i)
          ,p_trans_rec.SQUAL_NUM39(i)
          ,p_trans_rec.SQUAL_NUM40(i)
          ,p_trans_rec.SQUAL_NUM41(i)
          ,p_trans_rec.SQUAL_NUM42(i)
          ,p_trans_rec.SQUAL_NUM43(i)
          ,p_trans_rec.SQUAL_NUM44(i)
          ,p_trans_rec.SQUAL_NUM45(i)
          ,p_trans_rec.SQUAL_NUM46(i)
          ,p_trans_rec.SQUAL_NUM47(i)
          ,p_trans_rec.SQUAL_NUM48(i)
          ,p_trans_rec.SQUAL_NUM49(i)
          ,p_trans_rec.SQUAL_NUM50(i)
          ,l_sysdate
        );

      /*
              JTF_TERR_1003_OFFER_DYN.search_Terr_Rules(
                                p_Rec                 =>  p_trans_rec,
                                x_rec                 =>  lx_win_rec,
                                p_role                =>  p_role,
                                p_resource_type       =>  p_resource_type
              );
      */

    /* Trade Management/Claim */
    ELSIF ( p_source_id = -1003 AND p_trans_id = -1302) THEN
      l_program_name := 'TRADE MANAGEMENT/CLAIM PROGRAM';
      DELETE jty_terr_1003_claim_trans_gt;

      FORALL i IN p_trans_rec.trans_object_id.FIRST .. p_trans_rec.trans_object_id.LAST
        INSERT INTO jty_terr_1003_claim_trans_gt (
          use_type
          ,source_id
          ,transaction_id
          ,trans_object_id
          ,trans_detail_object_id
          ,SQUAL_CHAR01
          ,SQUAL_CHAR02
          ,SQUAL_CHAR03
          ,SQUAL_CHAR04
          ,SQUAL_CHAR05
          ,SQUAL_CHAR06
          ,SQUAL_CHAR07
          ,SQUAL_CHAR08
          ,SQUAL_CHAR09
          ,SQUAL_CHAR10
          ,SQUAL_CHAR11
          ,SQUAL_CHAR12
          ,SQUAL_CHAR13
          ,SQUAL_CHAR14
          ,SQUAL_CHAR15
          ,SQUAL_CHAR16
          ,SQUAL_CHAR17
          ,SQUAL_CHAR18
          ,SQUAL_CHAR19
          ,SQUAL_CHAR20
          ,SQUAL_CHAR21
          ,SQUAL_CHAR22
          ,SQUAL_CHAR23
          ,SQUAL_CHAR24
          ,SQUAL_CHAR25
          ,SQUAL_CHAR26
          ,SQUAL_CHAR27
          ,SQUAL_CHAR28
          ,SQUAL_CHAR29
          ,SQUAL_CHAR30
          ,SQUAL_CHAR31
          ,SQUAL_CHAR32
          ,SQUAL_CHAR33
          ,SQUAL_CHAR34
          ,SQUAL_CHAR35
          ,SQUAL_CHAR36
          ,SQUAL_CHAR37
          ,SQUAL_CHAR38
          ,SQUAL_CHAR39
          ,SQUAL_CHAR40
          ,SQUAL_CHAR41
          ,SQUAL_CHAR42
          ,SQUAL_CHAR43
          ,SQUAL_CHAR44
          ,SQUAL_CHAR45
          ,SQUAL_CHAR46
          ,SQUAL_CHAR47
          ,SQUAL_CHAR48
          ,SQUAL_CHAR49
          ,SQUAL_CHAR50
          ,SQUAL_NUM01
          ,SQUAL_NUM02
          ,SQUAL_NUM03
          ,SQUAL_NUM04
          ,SQUAL_NUM05
          ,SQUAL_NUM06
          ,SQUAL_NUM07
          ,SQUAL_NUM08
          ,SQUAL_NUM09
          ,SQUAL_NUM10
          ,SQUAL_NUM11
          ,SQUAL_NUM12
          ,SQUAL_NUM13
          ,SQUAL_NUM14
          ,SQUAL_NUM15
          ,SQUAL_NUM16
          ,SQUAL_NUM17
          ,SQUAL_NUM18
          ,SQUAL_NUM19
          ,SQUAL_NUM20
          ,SQUAL_NUM21
          ,SQUAL_NUM22
          ,SQUAL_NUM23
          ,SQUAL_NUM24
          ,SQUAL_NUM25
          ,SQUAL_NUM26
          ,SQUAL_NUM27
          ,SQUAL_NUM28
          ,SQUAL_NUM29
          ,SQUAL_NUM30
          ,SQUAL_NUM31
          ,SQUAL_NUM32
          ,SQUAL_NUM33
          ,SQUAL_NUM34
          ,SQUAL_NUM35
          ,SQUAL_NUM36
          ,SQUAL_NUM37
          ,SQUAL_NUM38
          ,SQUAL_NUM39
          ,SQUAL_NUM40
          ,SQUAL_NUM41
          ,SQUAL_NUM42
          ,SQUAL_NUM43
          ,SQUAL_NUM44
          ,SQUAL_NUM45
          ,SQUAL_NUM46
          ,SQUAL_NUM47
          ,SQUAL_NUM48
          ,SQUAL_NUM49
          ,SQUAL_NUM50
          ,txn_date
        )
        VALUES (
          p_use_type
          ,p_source_id
          ,p_trans_id
          ,p_trans_rec.trans_object_id(i)
          ,p_trans_rec.trans_detail_object_id(i)
          ,p_trans_rec.SQUAL_CHAR01(i)
          ,p_trans_rec.SQUAL_CHAR02(i)
          ,p_trans_rec.SQUAL_CHAR03(i)
          ,p_trans_rec.SQUAL_CHAR04(i)
          ,p_trans_rec.SQUAL_CHAR05(i)
          ,p_trans_rec.SQUAL_CHAR06(i)
          ,p_trans_rec.SQUAL_CHAR07(i)
          ,p_trans_rec.SQUAL_CHAR08(i)
          ,p_trans_rec.SQUAL_CHAR09(i)
          ,p_trans_rec.SQUAL_CHAR10(i)
          ,p_trans_rec.SQUAL_CHAR11(i)
          ,p_trans_rec.SQUAL_CHAR12(i)
          ,p_trans_rec.SQUAL_CHAR13(i)
          ,p_trans_rec.SQUAL_CHAR14(i)
          ,p_trans_rec.SQUAL_CHAR15(i)
          ,p_trans_rec.SQUAL_CHAR16(i)
          ,p_trans_rec.SQUAL_CHAR17(i)
          ,p_trans_rec.SQUAL_CHAR18(i)
          ,p_trans_rec.SQUAL_CHAR19(i)
          ,p_trans_rec.SQUAL_CHAR20(i)
          ,p_trans_rec.SQUAL_CHAR21(i)
          ,p_trans_rec.SQUAL_CHAR22(i)
          ,p_trans_rec.SQUAL_CHAR23(i)
          ,p_trans_rec.SQUAL_CHAR24(i)
          ,p_trans_rec.SQUAL_CHAR25(i)
          ,p_trans_rec.SQUAL_CHAR26(i)
          ,p_trans_rec.SQUAL_CHAR27(i)
          ,p_trans_rec.SQUAL_CHAR28(i)
          ,p_trans_rec.SQUAL_CHAR29(i)
          ,p_trans_rec.SQUAL_CHAR30(i)
          ,p_trans_rec.SQUAL_CHAR31(i)
          ,p_trans_rec.SQUAL_CHAR32(i)
          ,p_trans_rec.SQUAL_CHAR33(i)
          ,p_trans_rec.SQUAL_CHAR34(i)
          ,p_trans_rec.SQUAL_CHAR35(i)
          ,p_trans_rec.SQUAL_CHAR36(i)
          ,p_trans_rec.SQUAL_CHAR37(i)
          ,p_trans_rec.SQUAL_CHAR38(i)
          ,p_trans_rec.SQUAL_CHAR39(i)
          ,p_trans_rec.SQUAL_CHAR40(i)
          ,p_trans_rec.SQUAL_CHAR41(i)
          ,p_trans_rec.SQUAL_CHAR42(i)
          ,p_trans_rec.SQUAL_CHAR43(i)
          ,p_trans_rec.SQUAL_CHAR44(i)
          ,p_trans_rec.SQUAL_CHAR45(i)
          ,p_trans_rec.SQUAL_CHAR46(i)
          ,p_trans_rec.SQUAL_CHAR47(i)
          ,p_trans_rec.SQUAL_CHAR48(i)
          ,p_trans_rec.SQUAL_CHAR49(i)
          ,p_trans_rec.SQUAL_CHAR50(i)
          ,p_trans_rec.SQUAL_NUM01(i)
          ,p_trans_rec.SQUAL_NUM02(i)
          ,p_trans_rec.SQUAL_NUM03(i)
          ,p_trans_rec.SQUAL_NUM04(i)
          ,p_trans_rec.SQUAL_NUM05(i)
          ,p_trans_rec.SQUAL_NUM06(i)
          ,p_trans_rec.SQUAL_NUM07(i)
          ,p_trans_rec.SQUAL_NUM08(i)
          ,p_trans_rec.SQUAL_NUM09(i)
          ,p_trans_rec.SQUAL_NUM10(i)
          ,p_trans_rec.SQUAL_NUM11(i)
          ,p_trans_rec.SQUAL_NUM12(i)
          ,p_trans_rec.SQUAL_NUM13(i)
          ,p_trans_rec.SQUAL_NUM14(i)
          ,p_trans_rec.SQUAL_NUM15(i)
          ,p_trans_rec.SQUAL_NUM16(i)
          ,p_trans_rec.SQUAL_NUM17(i)
          ,p_trans_rec.SQUAL_NUM18(i)
          ,p_trans_rec.SQUAL_NUM19(i)
          ,p_trans_rec.SQUAL_NUM20(i)
          ,p_trans_rec.SQUAL_NUM21(i)
          ,p_trans_rec.SQUAL_NUM22(i)
          ,p_trans_rec.SQUAL_NUM23(i)
          ,p_trans_rec.SQUAL_NUM24(i)
          ,p_trans_rec.SQUAL_NUM25(i)
          ,p_trans_rec.SQUAL_NUM26(i)
          ,p_trans_rec.SQUAL_NUM27(i)
          ,p_trans_rec.SQUAL_NUM28(i)
          ,p_trans_rec.SQUAL_NUM29(i)
          ,p_trans_rec.SQUAL_NUM30(i)
          ,p_trans_rec.SQUAL_NUM31(i)
          ,p_trans_rec.SQUAL_NUM32(i)
          ,p_trans_rec.SQUAL_NUM33(i)
          ,p_trans_rec.SQUAL_NUM34(i)
          ,p_trans_rec.SQUAL_NUM35(i)
          ,p_trans_rec.SQUAL_NUM36(i)
          ,p_trans_rec.SQUAL_NUM37(i)
          ,p_trans_rec.SQUAL_NUM38(i)
          ,p_trans_rec.SQUAL_NUM39(i)
          ,p_trans_rec.SQUAL_NUM40(i)
          ,p_trans_rec.SQUAL_NUM41(i)
          ,p_trans_rec.SQUAL_NUM42(i)
          ,p_trans_rec.SQUAL_NUM43(i)
          ,p_trans_rec.SQUAL_NUM44(i)
          ,p_trans_rec.SQUAL_NUM45(i)
          ,p_trans_rec.SQUAL_NUM46(i)
          ,p_trans_rec.SQUAL_NUM47(i)
          ,p_trans_rec.SQUAL_NUM48(i)
          ,p_trans_rec.SQUAL_NUM49(i)
          ,p_trans_rec.SQUAL_NUM50(i)
          ,l_sysdate
        );

      /*
              JTF_TERR_1003_CLAIM_DYN.search_terr_rules(
                                p_rec                => p_trans_rec
                              , x_rec                => lx_win_rec
                              , p_role               => p_role
                              , p_resource_type      => p_resource_type );
      */

    /* Contracts/Contract Renewal */
    ELSIF ( p_source_id = -1500 AND p_trans_id = -1501) THEN
      l_program_name := 'CONTRACTS/CONTRACT RENEWALS PROGRAM';
      DELETE jty_terr_1500_cntrct_trans_gt;

      FORALL i IN p_trans_rec.trans_object_id.FIRST .. p_trans_rec.trans_object_id.LAST
        INSERT INTO jty_terr_1500_cntrct_trans_gt (
          use_type
          ,source_id
          ,transaction_id
          ,trans_object_id
          ,trans_detail_object_id
          ,SQUAL_CHAR01
          ,SQUAL_CHAR04
          ,SQUAL_CHAR07
          ,SQUAL_NUM01
          ,txn_date
        )
        VALUES (
          p_use_type
          ,p_source_id
          ,p_trans_id
          ,p_trans_rec.trans_object_id(i)
          ,p_trans_rec.trans_detail_object_id(i)
          ,p_trans_rec.SQUAL_CHAR01(i)
          ,p_trans_rec.SQUAL_CHAR04(i)
          ,p_trans_rec.SQUAL_CHAR07(i)
          ,p_trans_rec.SQUAL_NUM01(i)
          ,l_sysdate
        );

      /*
              JTF_TERR_1500_KREN_DYN.search_terr_rules(
                                p_rec                => p_trans_rec
                              , x_rec                => lx_win_rec
                              , p_role               => p_role
                              , p_resource_type      => p_resource_type );
      */

    /* Partner Management/Partner */
    ELSIF (p_source_id = -1700 AND p_trans_id = -1701) THEN
      l_program_name := 'TRADE MANAGEMENT/PARTNER PROGRAM';
      DELETE jty_terr_1700_partner_trans_gt;

      FORALL i IN p_trans_rec.trans_object_id.FIRST .. p_trans_rec.trans_object_id.LAST
        INSERT INTO jty_terr_1700_partner_trans_gt (
          use_type
          ,source_id
          ,transaction_id
          ,trans_object_id
          ,trans_detail_object_id
          ,SQUAL_CHAR01
          ,SQUAL_CHAR02
          ,SQUAL_CHAR03
          ,SQUAL_CHAR04
          ,SQUAL_CHAR05
          ,SQUAL_CHAR06
          ,SQUAL_CHAR07
          ,SQUAL_CHAR08
          ,SQUAL_CHAR09
          ,SQUAL_CHAR10
          ,SQUAL_CHAR11
          ,SQUAL_CHAR12
          ,SQUAL_CHAR13
          ,SQUAL_CHAR14
          ,SQUAL_CHAR15
          ,SQUAL_CHAR16
          ,SQUAL_CHAR17
          ,SQUAL_CHAR18
          ,SQUAL_CHAR19
          ,SQUAL_CHAR20
          ,SQUAL_NUM01
          ,SQUAL_NUM02
          ,SQUAL_NUM03
          ,SQUAL_NUM04
          ,SQUAL_NUM05
          ,SQUAL_NUM06
          ,SQUAL_NUM07
          ,SQUAL_NUM08
          ,SQUAL_NUM09
          ,SQUAL_NUM10
          ,SQUAL_NUM11
          ,SQUAL_NUM12
          ,SQUAL_NUM13
          ,SQUAL_NUM14
          ,SQUAL_NUM15
          ,SQUAL_NUM16
          ,SQUAL_NUM17
          ,SQUAL_NUM18
          ,SQUAL_NUM19
          ,SQUAL_NUM20
          ,SQUAL_CURC01
          ,txn_date
        )
        VALUES (
          p_use_type
          ,-1700
          ,-1701
          ,p_trans_rec.trans_object_id(i)
          ,p_trans_rec.trans_detail_object_id(i)
          ,p_trans_rec.SQUAL_CHAR01(i)
          ,p_trans_rec.SQUAL_CHAR02(i)
          ,p_trans_rec.SQUAL_CHAR03(i)
          ,p_trans_rec.SQUAL_CHAR04(i)
          ,p_trans_rec.SQUAL_CHAR05(i)
          ,p_trans_rec.SQUAL_CHAR06(i)
          ,p_trans_rec.SQUAL_CHAR07(i)
          ,p_trans_rec.SQUAL_CHAR08(i)
          ,p_trans_rec.SQUAL_CHAR09(i)
          ,p_trans_rec.SQUAL_CHAR10(i)
          ,p_trans_rec.SQUAL_CHAR11(i)
          ,p_trans_rec.SQUAL_CHAR12(i)
          ,p_trans_rec.SQUAL_CHAR13(i)
          ,p_trans_rec.SQUAL_CHAR14(i)
          ,p_trans_rec.SQUAL_CHAR15(i)
          ,p_trans_rec.SQUAL_CHAR16(i)
          ,p_trans_rec.SQUAL_CHAR17(i)
          ,p_trans_rec.SQUAL_CHAR18(i)
          ,p_trans_rec.SQUAL_CHAR19(i)
          ,p_trans_rec.SQUAL_CHAR20(i)
          ,p_trans_rec.SQUAL_NUM01(i)
          ,p_trans_rec.SQUAL_NUM02(i)
          ,p_trans_rec.SQUAL_NUM03(i)
          ,p_trans_rec.SQUAL_NUM04(i)
          ,p_trans_rec.SQUAL_NUM05(i)
          ,p_trans_rec.SQUAL_NUM06(i)
          ,p_trans_rec.SQUAL_NUM07(i)
          ,p_trans_rec.SQUAL_NUM08(i)
          ,p_trans_rec.SQUAL_NUM09(i)
          ,p_trans_rec.SQUAL_NUM10(i)
          ,p_trans_rec.SQUAL_NUM11(i)
          ,p_trans_rec.SQUAL_NUM12(i)
          ,p_trans_rec.SQUAL_NUM13(i)
          ,p_trans_rec.SQUAL_NUM14(i)
          ,p_trans_rec.SQUAL_NUM15(i)
          ,p_trans_rec.SQUAL_NUM16(i)
          ,p_trans_rec.SQUAL_NUM17(i)
          ,p_trans_rec.SQUAL_NUM18(i)
          ,p_trans_rec.SQUAL_NUM19(i)
          ,p_trans_rec.SQUAL_NUM20(i)
          ,p_trans_rec.SQUAL_CURC01(i)
          ,l_sysdate
        );

      /*
              JTF_TERR_1700_PARTNER_DYN.search_terr_rules(
                                p_rec                => p_trans_rec
                              , x_rec                => lx_win_rec
                              , p_role               => p_role
                              , p_resource_type      => p_resource_type );
      */

    ELSE  /* No Usage/Transaction Captured */

      NULL;

    END IF;

    JTY_ASSIGN_REALTIME_PUB.process_match (
           p_source_id     => p_source_id
          ,p_trans_id      => p_trans_id
          ,p_mode          => 'REAL TIME:' || p_use_type
          ,p_program_name  => l_program_name
          ,x_return_status => x_return_status
          ,x_msg_count     => x_msg_count
          ,x_msg_data      => x_msg_data);

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.jtf_terr_assign_pub.get_winners.process_match',
                       'API JTY_ASSIGN_REALTIME_PUB.process_match has failed');
      END IF;
      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    -- debug message
    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT,
                     'jtf.plsql.jtf_terr_assign_pub.get_winners.process_match',
                     'Finish calling procedure JTY_ASSIGN_REALTIME_PUB.process_match');
    END IF;

    JTY_ASSIGN_REALTIME_PUB.process_winners (
           p_source_id     => p_source_id
          ,p_trans_id      => p_trans_id
          ,p_program_name  => l_program_name
          ,p_mode          => 'REAL TIME:' || p_use_type
          ,p_role          => l_role
          ,p_resource_type => l_resource_type
          ,x_return_status => x_return_status
          ,x_msg_count     => x_msg_count
          ,x_msg_data      => x_msg_data
          ,x_winners_rec   => lx_winners_rec);

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                       'jtf.plsql.jtf_terr_assign_pub.get_winners.process_winners',
                       'JTY_ASSIGN_REALTIME_PUB.process_winners has failed');
      END IF;
      RAISE	FND_API.G_EXC_ERROR;
    END IF;

    -- debug message
    IF (FND_LOG.LEVEL_EVENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EVENT,
                     'jtf.plsql.jtf_terr_assign_pub.get_winners.process_winners',
                     'Finish calling procedure JTY_ASSIGN_REALTIME_PUB.process_winners');
    END IF;

    l_counter := lx_winners_rec.terr_id.FIRST;
    WHILE (l_counter <= lx_winners_rec.terr_id.LAST) LOOP

      x_winners_rec.trans_object_id.EXTEND;
      x_winners_rec.trans_detail_object_id.EXTEND;
      x_winners_rec.terr_id.EXTEND;
      x_winners_rec.terr_rsc_id.EXTEND;
      x_winners_rec.terr_name.EXTEND;
      x_winners_rec.top_level_terr_id.EXTEND;
      x_winners_rec.absolute_rank.EXTEND;
      x_winners_rec.resource_id.EXTEND;
      x_winners_rec.resource_type.EXTEND;
      x_winners_rec.group_id.EXTEND;
      x_winners_rec.role.EXTEND;
      x_winners_rec.full_access_flag.EXTEND;
      x_winners_rec.primary_contact_flag.EXTEND;

      x_winners_rec.trans_object_id(l_counter)        := lx_winners_rec.trans_object_id(l_counter);
      x_winners_rec.trans_detail_object_id(l_counter) := lx_winners_rec.trans_detail_object_id(l_counter);
      x_winners_rec.terr_id(l_counter)                := lx_winners_rec.terr_id(l_counter);
      x_winners_rec.terr_rsc_id(l_counter)            := lx_winners_rec.terr_rsc_id(l_counter);
      x_winners_rec.terr_name(l_counter)              := lx_winners_rec.terr_name(l_counter);
      x_winners_rec.top_level_terr_id(l_counter)      := lx_winners_rec.top_level_terr_id(l_counter);
      x_winners_rec.absolute_rank(l_counter)          := lx_winners_rec.absolute_rank(l_counter);
      x_winners_rec.resource_id(l_counter)            := lx_winners_rec.resource_id(l_counter);
      x_winners_rec.resource_type(l_counter)          := lx_winners_rec.resource_type(l_counter);
      x_winners_rec.group_id(l_counter)               := lx_winners_rec.group_id(l_counter);
      x_winners_rec.role(l_counter)                   := lx_winners_rec.role(l_counter);
      x_winners_rec.full_access_flag(l_counter)       := lx_winners_rec.full_access_flag(l_counter);
      x_winners_rec.primary_contact_flag(l_counter)   := lx_winners_rec.primary_contact_flag(l_counter);

      l_counter := l_counter + 1;

    END LOOP;

  END IF; /*  IF ( l_num_of_terr > 0 ) THEN */

  -- debug message
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.string(FND_LOG.LEVEL_PROCEDURE,
                   'jtf.plsql.jtf_terr_assign_pub.get_winners.end',
                   'End of the procedure jtf_terr_assign_pub.get_winners');
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_terr_assign_pub.get_winners.g_exc_error',
                     substr(x_msg_data, 1, 4000));
    END IF;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    x_msg_data := SQLCODE || ' : ' || SQLERRM;
    x_msg_count := 1;
    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.string(FND_LOG.LEVEL_EXCEPTION,
                     'jtf.plsql.jtf_terr_assign_pub.get_winners.other',
                     substr(x_msg_data, 1, 4000));
    END IF;

End  Get_Winners;

END JTF_TERR_ASSIGN_PUB;

/
