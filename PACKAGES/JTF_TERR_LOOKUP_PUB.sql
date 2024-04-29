--------------------------------------------------------
--  DDL for Package JTF_TERR_LOOKUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TERR_LOOKUP_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfplkus.pls 120.0 2005/06/02 18:20:45 appldev ship $ */

---------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_LOOKUP_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force territory lookup tool api's.
--      This package is a public API for getting winning territories
--      or territory resources.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      11/06/00    EIHSU           Created
--      01/07/01    EIHSU           API-side resource detail extraction
--      01/29/01    EIHSU           Includes 255 -> 360 fix for bug 1614487
--      09/28/01    ARPATEL         changing to generic table-of-records architecture
--      10/10/01    ARPATEL         added p_source_id and p_trans_id to get_Winners
--      10/22/01    ARPATEL         adding extra parameters to get_org_contacts
--      10/23/01    ARPATEL         changing org_name_rec_type to include area_code, employees_total, category_code and sic_code
--    End of Comments
--

---------------------------------------------------------
--               Account record format
--    ---------------------------------------------------
--    Parameters:
--    Required:
--    Defaults:
--    Note:
--
-- End of Comments

-- ***************************************************
--    GLOBAL VARIABLES and RECORD TYPE DEFINITIONS
-- ***************************************************

    /* ---------------------------------------------------
    -- RECORD TYPE: trans_rec_type
    --
    -- Description:
    --      Territories generic assignment request type.
    --      All requests for territory assignments inputted with
    --      this type.
    -- Notes:
    --      GENERIC BULK record format copied from JTF_TERRITORY_PUB
    --      On 6/25/2001
    --
    -- ----------------------------------------------------*/

    TYPE trans_rec_type IS RECORD (

        -- logic control properties
        use_type                    VARCHAR2(30), -- refer to body for valid values of this parameter
        source_id                   NUMBER,
        transaction_id              NUMBER,
        trans_object_id             NUMBER        := FND_API.G_MISS_NUM,
        trans_detail_object_id      NUMBER        := FND_API.G_MISS_NUM,

        -- transaction qualifier values
        SQUAL_CHAR01                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR02                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR03                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR04                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR05                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR06                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR07                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR08                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR09                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR10                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR11                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR12                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR13                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR14                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR15                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR16                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR17                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR18                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR19                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR20                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR21                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR22                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR23                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR24                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR25                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR26                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR27                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR28                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR29                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR30                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR31                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR32                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR33                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR34                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR35                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR36                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR37                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR38                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR39                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR40                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR41                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR42                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR43                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR44                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR45                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR46                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR47                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR48                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR49                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        SQUAL_CHAR50                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,

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
        SQUAL_NUM26                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM27                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM28                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM29                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM30                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM31                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM32                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM33                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM34                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM35                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM36                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM37                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM38                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM39                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM40                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM41                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM42                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM43                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM44                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM45                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM46                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM47                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM48                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM49                    NUMBER        := FND_API.G_MISS_NUM,
        SQUAL_NUM50                    NUMBER        := FND_API.G_MISS_NUM
        );

    G_MISS_TRANS_REC      trans_rec_type;

    /* TYPE trans_tbl_type   IS TABLE OF   trans_rec_type
                           INDEX BY BINARY_INTEGER;
    */


TYPE org_name_rec_type IS record
  (party_id         number(15),
   location_id      number(15),
   party_site_id    number(15),
   party_site_use_id number(15),
   party_name       varchar2(360),
   address          varchar2(240),
   city             varchar2(60),
   state            varchar2(60),
   province         varchar2(60),
   postal_code      varchar2(60),
   area_code        varchar2(60),
   county           varchar2(60),
   country          varchar2(60),
   employees_total  number(15),
   category_code    varchar2(60),
   sic_code         varchar2(60),
   primary_flag     varchar2(1),
   status           varchar2(1),
   address_type     varchar2(30),
   property1        varchar2(60),
   property2        varchar2(60),
   property3        varchar2(60),
   property4        varchar2(60),
   property5        varchar2(60));

TYPE org_name_tbl_type IS table OF org_name_rec_type
  INDEX BY binary_integer;


-- This record_type stores the winning resource and their properties for the territory lookup
TYPE win_rsc_rec_type IS record
    (resource_id        NUMBER          := FND_API.G_MISS_NUM,
     terr_id            NUMBER          := FND_API.G_MISS_NUM,
     resource_name        varchar2(150)   := FND_API.G_MISS_CHAR,
     resource_phone       varchar2(150)   := FND_API.G_MISS_CHAR,
     resource_job_title   varchar2(150)   := FND_API.G_MISS_CHAR,
     resource_email       varchar2(150)   := FND_API.G_MISS_CHAR,
     resource_mgr_name    varchar2(150)   := FND_API.G_MISS_CHAR,
     resource_mgr_phone   varchar2(150)   := FND_API.G_MISS_CHAR,
     resource_mgr_email   varchar2(150)   := FND_API.G_MISS_CHAR,
     resource_property1   varchar2(150)   := FND_API.G_MISS_CHAR,
     resource_property2   varchar2(150)   := FND_API.G_MISS_CHAR,
     resource_property3   varchar2(150)   := FND_API.G_MISS_CHAR,
     resource_property4   varchar2(150)   := FND_API.G_MISS_CHAR
     );

TYPE win_rsc_tbl_type IS table of win_rsc_rec_type
    INDEX BY binary_integer;


-- This record_type stores the winning resource and their properties for the territory lookup

 TYPE winners_rec_type IS RECORD (

        -- logic control properties

        use_type                    VARCHAR2(30), -- refer to body for valid values of this parameter
        source_id                   NUMBER,
        transaction_id              NUMBER,
        trans_object_id             NUMBER        := FND_API.G_MISS_NUM,
        trans_detail_object_id      NUMBER        := FND_API.G_MISS_NUM,

        -- territory definition properties
        terr_id                     NUMBER        := FND_API.G_MISS_NUM,
        terr_rsc_id                 NUMBER        := FND_API.G_MISS_NUM,
        terr_name                   NUMBER        := FND_API.G_MISS_NUM,
        top_level_terr_id           NUMBER        := FND_API.G_MISS_NUM,
        absolute_rank               NUMBER        := FND_API.G_MISS_NUM,

        -- resource definition properties
        resource_id                 NUMBER        := FND_API.G_MISS_NUM,
        resource_type               VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        group_id                    NUMBER        := FND_API.G_MISS_NUM,
        role                        VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        full_access_flag            VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        primary_contact_flag        VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        resource_name               VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        resource_job_title          VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        resource_phone              VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        resource_email              VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        resource_mgr_name           VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        resource_mgr_phone          VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        resource_mgr_email          VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        property1                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        property2                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        property3                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        property4                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        property5                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        property6                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        property7                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        property8                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        property9                   VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        property10                  VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        property11                  VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        property12                  VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        property13                  VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        property14                  VARCHAR2(360)  := FND_API.G_MISS_CHAR,
        property15                  VARCHAR2(360)  := FND_API.G_MISS_CHAR


        ); -- end bulk_terr_winners_rec_type


TYPE winners_tbl_type IS table of winners_rec_type
                      INDEX BY binary_integer;


-- ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_Organizations
--    type           : public.
--    function       : Get the Organization Contact info
--    pre-reqs       : depends on hz_parties table
--    parameters     :
-- end of comments

procedure Get_Org_Contacts
(   p_range_low           IN NUMBER,
    p_range_high          IN NUMBER,
    p_search_name         IN VARCHAR2,
    p_state               IN VARCHAR2,
    p_country             IN VARCHAR2,
    p_postal_code         IN VARCHAR2,
    p_attribute1          IN VARCHAR2,
    p_attribute2          IN VARCHAR2,
    p_attribute3          IN VARCHAR2,
    p_attribute4          IN VARCHAR2,
    p_attribute5          IN VARCHAR2,
    p_attribute6          IN VARCHAR2,
    p_attribute7          IN VARCHAR2,
    p_attribute8          IN VARCHAR2,
    p_attribute9          IN VARCHAR2,
    p_attribute10         IN VARCHAR2,
    p_attribute11         IN VARCHAR2,
    p_attribute12         IN VARCHAR2,
    p_attribute13         IN VARCHAR2,
    p_attribute14         IN VARCHAR2,
    p_attribute15         IN VARCHAR2,
    x_total_rows          OUT NOCOPY NUMBER,
    x_result_tbl          OUT NOCOPY org_name_tbl_type);


--    ***************************************************
--    start of comments
--    ***************************************************
--    api name       : Get_WinningTerrMembers
--    type           : public.
--    function       : Get winning territories members for an ACCOUNT
--    pre-reqs       : Territories needs to be setup first
--    parameters     :
--
--    IN:
--        p_api_version_number   IN  number               required
--        p_init_msg_list        IN  varchar2             optional --default = fnd_api.g_false
--        p_commit               IN  varchar2             optional --default = fnd_api.g_false
--        p_Org_Id               IN  number               required
--        p_TerrAccount_Rec      IN  JTF_Account_rec_type
--        p_Resource_Type        IN  varchar2
--        p_Role                 IN  varchar2,
--
--    out:
--        x_return_status        out varchar2(1)
--        x_msg_count            out number
--        x_msg_data             out varchar2(2000)
--        x_TerrRes_tbl          out TerrRes_tbl_type
--
--    requirements   :
--    business rules :

--    version        :    current version    1.0
--    initial version:    initial version    1.0
--
--    notes:              Public API for retreving a set of winning
--                        territories resources. This is an overloaded
--                        procedure for accounts,lead, oppor, service
--                        requests, and collections.
--
-- end of comments
procedure Get_Winners
(   p_api_version_number       IN    number,
    p_init_msg_list            IN    varchar2  := fnd_api.g_false,
    p_trans_rec                IN    trans_rec_type,
    p_source_id                IN    number,
    p_trans_id                 IN    number,
    p_Resource_Type            IN    varchar2,
    p_Role                     IN    varchar2,
    x_return_status            OUT NOCOPY   varchar2,
    x_msg_count                OUT NOCOPY   number,
    X_msg_data                 OUT NOCOPY   varchar2,
    x_winners_tbl              OUT NOCOPY   winners_tbl_type
);

END JTF_TERR_LOOKUP_PUB;

 

/
