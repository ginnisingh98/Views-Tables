--------------------------------------------------------
--  DDL for Package JTY_ASSIGN_REALTIME_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTY_ASSIGN_REALTIME_PUB" AUTHID CURRENT_USER AS
/* $Header: jtftraes.pls 120.2.12010000.2 2008/12/11 07:13:02 vpalle ship $ */
---------------------------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTY_ASSIGN_REALTIME_PUB
--    ---------------------------------------------------
--    PURPOSE
--      This package is a public API for getting winning territories
--      or territory resources in real time.
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      05/04/05    achanda    CREATED
--
--
--    End of Comments

-- ***************************************************
--    GLOBAL VARIABLES and RECORD TYPE DEFINITIONS
-- ***************************************************

  /* ---------------------------------------------------
  -- RECORD TYPE: bulk_trans_id_type
  --
  -- Description:
  --      Product teams using "pass by reference" as parameter passing mechanism
  --      should use this type to pass the PK of the transaction objects to the
  --      territory assignment API for real time and date effective assignment.
  --
  -- Notes:
  --
  -- ----------------------------------------------------*/

  TYPE bulk_trans_id_type IS RECORD (

    -- PK of the transaction objects
    trans_object_id1            jtf_terr_number_list := jtf_terr_number_list() ,
    trans_object_id2            jtf_terr_number_list := jtf_terr_number_list() ,
    trans_object_id3            jtf_terr_number_list := jtf_terr_number_list() ,
    trans_object_id4            jtf_terr_number_list := jtf_terr_number_list() ,
    trans_object_id5            jtf_terr_number_list := jtf_terr_number_list() ,

    -- transaction date, applicable only for date effective assignment
    txn_date                    jtf_terr_date_list   := jtf_terr_date_list()
  );

  G_MISS_BULK_TRANS_ID  bulk_trans_id_type;

  /* ---------------------------------------------------
  -- RECORD TYPE: bulk_name_value_pair_type
  --
  -- Description:
  --      Product teams using "pass by value" as parameter passing mechanism
  --      should use this type to pass the attribute name and its value of the
  --      transaction objects to the territory assignment API for real time assignment.
  --
  -- Notes:
  --      attribute_name : Name of the attribute
  --      num_value  : value of the attribute if the datatype is NUMBER
  --      date_value : value of the attribute if the datatype is DATE
  --      char_value : value of the attribute if the datatype is CHAR
  -- ----------------------------------------------------*/

  TYPE bulk_name_value_pair_type IS RECORD (

    -- Attribute Name and its value
    attribute_name              jtf_terr_char_360list := jtf_terr_char_360list() ,
    num_value                   jtf_terr_number_list  := jtf_terr_number_list() ,
    date_value                  jtf_terr_date_list    := jtf_terr_date_list() ,
    char_value                  jtf_terr_char_360list := jtf_terr_char_360list()
  );

  G_MISS_BULK_NAME_VALUE_PAIR  bulk_name_value_pair_type;


  /* ---------------------------------------------------
  -- RECORD TYPE: bulk_terr_winners_rec_type
  --
  -- Description:
  --      Territories generic assignment return type.
  --      All results from territory assignments outputted to
  --      this type.
  -- Notes:
  --
  -- ---------------------------------------------------*/

  TYPE bulk_winners_rec_type IS RECORD (

    -- logic control properties
    use_type                    VARCHAR2(30),
    source_id                   NUMBER,
    trans_id                    NUMBER,
    trans_object_id             jtf_terr_number_list := jtf_terr_number_list() ,
    trans_detail_object_id      jtf_terr_number_list := jtf_terr_number_list() ,
    txn_date                    jtf_terr_date_list   := jtf_terr_date_list(),

    -- territory definition properties
    terr_id                     jtf_terr_number_list  := jtf_terr_number_list() ,
    org_id                      jtf_terr_number_list  := jtf_terr_number_list() ,
    terr_start_date             jtf_terr_date_list    := jtf_terr_date_list(),
    terr_end_date               jtf_terr_date_list    := jtf_terr_date_list(),
    terr_rsc_id                 jtf_terr_number_list  := jtf_terr_number_list() ,
    terr_name                   jtf_terr_char_360list := jtf_terr_char_360list() ,
    top_level_terr_id           jtf_terr_number_list  := jtf_terr_number_list() ,
    absolute_rank               jtf_terr_number_list  := jtf_terr_number_list() ,

    -- resource definition properties
    resource_id                 jtf_terr_number_list  := jtf_terr_number_list() ,
    rsc_start_date              jtf_terr_date_list    := jtf_terr_date_list(),
    rsc_end_date                jtf_terr_date_list    := jtf_terr_date_list(),
    resource_type               jtf_terr_char_360list := jtf_terr_char_360list() ,
    group_id                    jtf_terr_number_list  := jtf_terr_number_list() ,
    role_id                     jtf_terr_number_list  := jtf_terr_number_list() ,
    role                        jtf_terr_char_360list := jtf_terr_char_360list() ,
    full_access_flag            jtf_terr_char_360list := jtf_terr_char_360list() ,
    primary_contact_flag        jtf_terr_char_360list := jtf_terr_char_360list() ,
    resource_name               jtf_terr_char_360list := jtf_terr_char_360list() ,
    resource_job_title          jtf_terr_char_360list := jtf_terr_char_360list() ,
    resource_phone              jtf_terr_char_360list := jtf_terr_char_360list() ,
    resource_email              jtf_terr_char_360list := jtf_terr_char_360list() ,
    resource_mgr_name           jtf_terr_char_360list := jtf_terr_char_360list() ,
    resource_mgr_phone          jtf_terr_char_360list := jtf_terr_char_360list() ,
    resource_mgr_email          jtf_terr_char_360list := jtf_terr_char_360list() ,
    person_id                   jtf_terr_number_list  := jtf_terr_number_list() ,
    property1                   jtf_terr_char_360list := jtf_terr_char_360list() ,
    property2                   jtf_terr_char_360list := jtf_terr_char_360list() ,
    property3                   jtf_terr_char_360list := jtf_terr_char_360list() ,
    property4                   jtf_terr_char_360list := jtf_terr_char_360list() ,
    property5                   jtf_terr_char_360list := jtf_terr_char_360list() ,
    property6                   jtf_terr_char_360list := jtf_terr_char_360list() ,
    property7                   jtf_terr_char_360list := jtf_terr_char_360list() ,
    property8                   jtf_terr_char_360list := jtf_terr_char_360list() ,
    property9                   jtf_terr_char_360list := jtf_terr_char_360list() ,
    property10                  jtf_terr_char_360list := jtf_terr_char_360list() ,
    property11                  jtf_terr_char_360list := jtf_terr_char_360list() ,
    property12                  jtf_terr_char_360list := jtf_terr_char_360list() ,
    property13                  jtf_terr_char_360list := jtf_terr_char_360list() ,
    property14                  jtf_terr_char_360list := jtf_terr_char_360list() ,
    property15                  jtf_terr_char_360list := jtf_terr_char_360list() ,

    -- decsriptive flexfields for territory
    terr_attr_category          jtf_terr_char_360list := jtf_terr_char_360list() ,
    terr_attribute1             jtf_terr_char_360list := jtf_terr_char_360list() ,
    terr_attribute2             jtf_terr_char_360list := jtf_terr_char_360list() ,
    terr_attribute3             jtf_terr_char_360list := jtf_terr_char_360list() ,
    terr_attribute4             jtf_terr_char_360list := jtf_terr_char_360list() ,
    terr_attribute5             jtf_terr_char_360list := jtf_terr_char_360list() ,
    terr_attribute6             jtf_terr_char_360list := jtf_terr_char_360list() ,
    terr_attribute7             jtf_terr_char_360list := jtf_terr_char_360list() ,
    terr_attribute8             jtf_terr_char_360list := jtf_terr_char_360list() ,
    terr_attribute9             jtf_terr_char_360list := jtf_terr_char_360list() ,
    terr_attribute10            jtf_terr_char_360list := jtf_terr_char_360list() ,
    terr_attribute11            jtf_terr_char_360list := jtf_terr_char_360list() ,
    terr_attribute12            jtf_terr_char_360list := jtf_terr_char_360list() ,
    terr_attribute13            jtf_terr_char_360list := jtf_terr_char_360list() ,
    terr_attribute14            jtf_terr_char_360list := jtf_terr_char_360list() ,
    terr_attribute15            jtf_terr_char_360list := jtf_terr_char_360list() ,

    -- decsriptive flexfields for resource
    rsc_attr_category           jtf_terr_char_360list := jtf_terr_char_360list() ,
    rsc_attribute1              jtf_terr_char_360list := jtf_terr_char_360list() ,
    rsc_attribute2              jtf_terr_char_360list := jtf_terr_char_360list() ,
    rsc_attribute3              jtf_terr_char_360list := jtf_terr_char_360list() ,
    rsc_attribute4              jtf_terr_char_360list := jtf_terr_char_360list() ,
    rsc_attribute5              jtf_terr_char_360list := jtf_terr_char_360list() ,
    rsc_attribute6              jtf_terr_char_360list := jtf_terr_char_360list() ,
    rsc_attribute7              jtf_terr_char_360list := jtf_terr_char_360list() ,
    rsc_attribute8              jtf_terr_char_360list := jtf_terr_char_360list() ,
    rsc_attribute9              jtf_terr_char_360list := jtf_terr_char_360list() ,
    rsc_attribute10             jtf_terr_char_360list := jtf_terr_char_360list() ,
    rsc_attribute11             jtf_terr_char_360list := jtf_terr_char_360list() ,
    rsc_attribute12             jtf_terr_char_360list := jtf_terr_char_360list() ,
    rsc_attribute13             jtf_terr_char_360list := jtf_terr_char_360list() ,
    rsc_attribute14             jtf_terr_char_360list := jtf_terr_char_360list() ,
    rsc_attribute15             jtf_terr_char_360list := jtf_terr_char_360list()

  ); -- end bulk_winners_rec_type

  G_MISS_BULK_WINNERS_REC      bulk_winners_rec_type;

  -- ***************************************************
  --    API Specifications
  -- ***************************************************
  --    api name       : Get_Winners
  --    type           : public.
  --    function       : For all Real Time Territory Assignment request purposes.
  --    pre-reqs       : Territories needs to be setup first
  --    notes          : Generic public API for retreving any of the following
  --                        * Winning Resource Id's
  --                        * Winning Resource Names + Details
  --                        * Winning terr_id's
  --
  PROCEDURE get_winners
  (   p_api_version_number       IN          NUMBER := 1,
      p_init_msg_list            IN          VARCHAR2 := FND_API.G_FALSE,
      p_source_id                IN          NUMBER,
      p_trans_id                 IN          NUMBER,
      p_mode                     IN          VARCHAR2,
      p_param_passing_mechanism  IN          VARCHAR2,
      p_program_name             IN          VARCHAR2,
      p_trans_rec                IN          bulk_trans_id_type := G_MISS_BULK_TRANS_ID,
      p_name_value_pair          IN          bulk_name_value_pair_type := G_MISS_BULK_NAME_VALUE_PAIR,
      p_role                     IN          VARCHAR2 := NULL,
      p_resource_type            IN          VARCHAR2 := NULL,
      x_return_status            OUT NOCOPY  VARCHAR2,
      x_msg_count                OUT NOCOPY  NUMBER,
      x_msg_data                 OUT NOCOPY  VARCHAR2,
      x_winners_rec              OUT NOCOPY  bulk_winners_rec_type
  );

  -- ***************************************************
  --    API Specifications
  -- ***************************************************
  --    api name       : Process_match
  --    type           : public.
  --    function       : Called from 11.5.10 real time APIs
  --    pre-reqs       : Territories needs to be setup first
  --    notes          : Not to be called by product team
  --
  PROCEDURE process_match
  (   p_source_id                IN          NUMBER,
      p_trans_id                 IN          NUMBER,
      p_mode                     IN          VARCHAR2,
      p_program_name             IN          VARCHAR2,
      x_return_status            OUT NOCOPY  VARCHAR2,
      x_msg_count                OUT NOCOPY  NUMBER,
      x_msg_data                 OUT NOCOPY  VARCHAR2
  );

  -- ***************************************************
  --    API Specifications
  -- ***************************************************
  --    api name       : Process_Winners
  --    type           : public.
  --    function       : Called from 11.5.10 real time APIs
  --    pre-reqs       : Territories needs to be setup first
  --    notes          : Not to be called by product team
  --
  PROCEDURE process_winners
  (   p_source_id                IN          NUMBER,
      p_trans_id                 IN          NUMBER,
      p_program_name             IN          VARCHAR2,
      p_mode                     IN          VARCHAR2,
      p_role                     IN          VARCHAR2,
      p_resource_type            IN          VARCHAR2,
      p_plan_start_date          IN    DATE DEFAULT NULL,
      p_plan_end_date            IN    DATE DEFAULT NULL,
      x_return_status            OUT NOCOPY  VARCHAR2,
      x_msg_count                OUT NOCOPY  NUMBER,
      x_msg_data                 OUT NOCOPY  VARCHAR2,
      x_winners_rec              OUT NOCOPY  bulk_winners_rec_type
  );

END JTY_ASSIGN_REALTIME_PUB;

/
