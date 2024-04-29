--------------------------------------------------------
--  DDL for Package PV_ENRQ_BINS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_ENRQ_BINS_PVT" AUTHID CURRENT_USER as
/* $Header: pvxvbins.pls 120.0 2005/05/27 16:18:19 appldev noship $*/



TYPe enrq_param_ref IS REF CURSOR;

   PROCEDURE new_programs
   (
      p_api_version_number          IN   NUMBER
      ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
      ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
      ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
      ,p_partner_id                 IN   NUMBER
      ,p_member_type                IN   VARCHAR2
      ,p_isprereq_eval              IN   VARCHAR2     :='Y'
      ,x_enrq_param_cur             OUT  NOCOPY enrq_param_ref
      ,x_return_status              OUT  NOCOPY VARCHAR2
      ,x_msg_count                  OUT  NOCOPY NUMBER
      ,x_msg_data                   OUT  NOCOPY VARCHAR2
   );



   PROCEDURE renewable_programs
   (
      p_api_version_number          IN   NUMBER
      ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
      ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
      ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
      ,p_partner_id                 IN   NUMBER
      ,p_member_type                IN   VARCHAR2
      ,p_isprereq_eval              IN   VARCHAR2     :='Y'
      ,x_enrq_param_cur             OUT  NOCOPY enrq_param_ref
      ,x_return_status              OUT  NOCOPY VARCHAR2
      ,x_msg_count                  OUT  NOCOPY NUMBER
      ,x_msg_data                   OUT  NOCOPY VARCHAR2
   );


   PROCEDURE upgradable_programs
   (
      p_api_version_number          IN   NUMBER
      ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
      ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
      ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
      ,p_partner_id                 IN   NUMBER
      ,p_member_type                IN   VARCHAR2
      ,p_isprereq_eval              IN   VARCHAR2     :='Y'
      ,x_enrq_param_cur             OUT  NOCOPY enrq_param_ref
      ,x_return_status              OUT  NOCOPY VARCHAR2
      ,x_msg_count                  OUT  NOCOPY NUMBER
      ,x_msg_data                   OUT  NOCOPY VARCHAR2
   );




   PROCEDURE incomplete_programs
   (
       p_api_version_number          IN   NUMBER
      ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
      ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
      ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
      ,p_partner_id                 IN   NUMBER
      ,p_member_type                IN   VARCHAR2
      ,p_isprereq_eval              IN   VARCHAR2     :='Y'
      ,x_enrq_param_cur             OUT  NOCOPY enrq_param_ref
      ,x_return_status              OUT  NOCOPY VARCHAR2
      ,x_msg_count                  OUT  NOCOPY NUMBER
      ,x_msg_data                   OUT  NOCOPY VARCHAR2
   );


   PROCEDURE newAndInCompletePrograms
   (
      p_api_version_number          IN   NUMBER
      ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
      ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
      ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
      ,p_partner_id                 IN   NUMBER
      ,p_member_type                IN   VARCHAR2
      ,p_isprereq_eval              IN   VARCHAR2     :='Y'
      ,x_enrq_param_cur             OUT  NOCOPY enrq_param_ref
      ,x_return_status              OUT  NOCOPY VARCHAR2
      ,x_msg_count                  OUT  NOCOPY NUMBER
      ,x_msg_data                   OUT  NOCOPY VARCHAR2
   );

   PROCEDURE isPartnerEligible
   (
      p_api_version_number           IN   NUMBER
      , p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
      , p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
      , p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
      , p_partner_id                 IN   NUMBER
      , p_from_program_id            IN   NUMBER
      , p_to_program_id              IN   NUMBER
      , p_enrq_type                  IN   VARCHAR  -- permitted values here are 'NEW', 'UPGRADE' for 11.5.10.
      , x_elig_flag                  OUT  NOCOPY VARCHAR2 -- PASS 'Y' if eligible, PASS 'N' if not eligible
      , x_return_status              OUT  NOCOPY VARCHAR2
      , x_msg_count                  OUT  NOCOPY NUMBER
      , x_msg_data                   OUT  NOCOPY VARCHAR2
   );

END Pv_Enrq_Bins_PVT;

 

/
