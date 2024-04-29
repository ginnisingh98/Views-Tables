--------------------------------------------------------
--  DDL for Package OZF_OBJFUNDSUM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_OBJFUNDSUM_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvfsus.pls 120.3.12010000.2 2009/06/19 08:41:36 kdass ship $ */

--
-- Start of comments.
--
-- NAME
--   Ozf_objfundsum_Pvt  12.0
--
-- PURPOSE
--   This package is a private package used for captures object's planned/committed/utilized/earned/paid amount at object-budget level
--
--   Procedures:
--   Create_ObjFundSum
--   Update_ObjFundSum
--   Validate_ObjFundSum
--   Complete_ObjFundSum_Rec
--   Init_ObjFundSum_Rec
-- NOTES
--
--
-- HISTORY
--   06/30/2005   YZHAO      creation
--   06/12/2009   kdass      bug 8532055 - ADD EXCHANGE RATE DATE PARAM TO OZF_FUND_UTILIZED_PUB.CREATE_FUND_ADJUSTMENT API
--
TYPE objfundsum_rec_type
IS RECORD (
       objfundsum_id                        NUMBER,
       last_update_date                 DATE,
       last_updated_by                  NUMBER,
       creation_date                    DATE,
       created_by                       NUMBER,
       last_update_login                NUMBER,
       object_version_number            NUMBER,
       fund_id                          NUMBER,
       fund_currency                    VARCHAR2(30),
       object_type                      VARCHAR2(30),
       object_id                        NUMBER,
       object_currency                  VARCHAR2(30),
       reference_object_type            VARCHAR2(30),
       reference_object_id              NUMBER,
       source_from_parent               VARCHAR2(1),
       planned_amt                      NUMBER,
       committed_amt                    NUMBER,
       recal_committed_amt              NUMBER,
       utilized_amt                     NUMBER,
       earned_amt                       NUMBER,
       paid_amt                         NUMBER,
       plan_curr_planned_amt            NUMBER,
       plan_curr_committed_amt          NUMBER,
       plan_curr_recal_committed_amt    NUMBER,
       plan_curr_utilized_amt           NUMBER,
       plan_curr_earned_amt             NUMBER,
       plan_curr_paid_amt               NUMBER,
       univ_curr_planned_amt            NUMBER,
       univ_curr_committed_amt          NUMBER,
       univ_curr_recal_committed_amt    NUMBER,
       univ_curr_utilized_amt           NUMBER,
       univ_curr_earned_amt             NUMBER,
       univ_curr_paid_amt               NUMBER,
       attribute_category               VARCHAR2(30),
       attribute1                       VARCHAR2(150),
       attribute2                       VARCHAR2(150),
       attribute3                       VARCHAR2(150),
       attribute4                       VARCHAR2(150),
       attribute5                       VARCHAR2(150),
       attribute6                       VARCHAR2(150),
       attribute7                       VARCHAR2(150),
       attribute8                       VARCHAR2(150),
       attribute9                       VARCHAR2(150),
       attribute10                      VARCHAR2(150),
       attribute11                      VARCHAR2(150),
       attribute12                      VARCHAR2(150),
       attribute13                      VARCHAR2(150),
       attribute14                      VARCHAR2(150),
       attribute15                      VARCHAR2(150)
);


-- NAME
--    create_objfundsum
--
-- PURPOSE
--    This Procedure creates a record in object fund summary table.
--
-- NOTES
--
--
PROCEDURE Create_objfundsum (
   p_api_version                IN      NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level           IN  NUMBER   := Fnd_Api.G_Valid_Level_Full,
   p_objfundsum_rec             IN  objfundsum_rec_type,
   p_conv_date                  IN  DATE DEFAULT NULL, --bug 8532055
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   x_objfundsum_id              OUT NOCOPY NUMBER
);



-- NAME
--    update_objfundsum
--
-- PURPOSE
--    This Procedure updates record in object fund summary table.
--      it overwrites record if the filed(e.g. earned_amount) is passed in
--
-- NOTES
--
--
PROCEDURE Update_objfundsum (
   p_api_version                IN      NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level           IN  NUMBER   := Fnd_Api.G_VALID_LEVEL_FULL,
   p_objfundsum_rec             IN      objfundsum_rec_type,
   p_conv_date                  IN  DATE DEFAULT NULL, --bug 8532055
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);


-- NAME
--    process_objfundsum
--
-- PURPOSE
--    This Procedure creates a record in object fund summary table if it's not there.
--                   update  a record in object fund summary table if it's already there
--                   for update, it does cumulative update. E.g. existing record has earned_amount=$100
--                               if p_objfundsum_rec.earned_amount=$50, after this call earned_amount=$150
--
-- NOTES
--
--
PROCEDURE process_objfundsum (
   p_api_version                IN      NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level           IN  NUMBER   := Fnd_Api.G_Valid_Level_Full,
   p_objfundsum_rec             IN  objfundsum_rec_type,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,
   x_objfundsum_id              OUT NOCOPY NUMBER
);


-- NAME
--    validate_objfundsum
--
-- PURPOSE
--    This Procedure validates record in object fund summary table.
--
-- NOTES
--
--
PROCEDURE Validate_objfundsum (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_validation_level           IN  NUMBER   := Fnd_Api.G_Valid_Level_Full,
   p_objfundsum_rec            IN   objfundsum_rec_type,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
);



-- NAME
--    complete_objfundsum_rec
--
-- PURPOSE
--    This Procedure completes record in object fund summary table.
--
-- NOTES
--
--
PROCEDURE Complete_objfundsum_Rec(
   p_objfundsum_rec      IN  objfundsum_rec_type,
   x_complete_rec        IN OUT NOCOPY objfundsum_rec_type
);


END ozf_objfundsum_pvt;

/
