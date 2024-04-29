--------------------------------------------------------
--  DDL for Package AMS_ACTMETRICFACT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACTMETRICFACT_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvamfs.pls 115.13 2002/11/16 01:09:39 mgudivak ship $ */

--
-- Start of comments.
--
-- NAME
--   Ams_ActMetricsFact_Pvt
--
-- PURPOSE
--   This package is a private package used for defining constants, records,
--   types and procedures for activity metric facts API.
--
--   Procedures:
--   Create_ActMetricFact
--   Update_ActMetricFact
--   Lock_ActMetricFact
--   Delete_ActMetricFact
--   Validate_ActMetricFact
--
-- NOTES
--
--
-- HISTORY
-- 18/Apr/2000 tdonohoe  Created.
--
-- Start AMS_ACT_METRIC_FACTS_ALL
--

TYPE act_metric_fact_rec_type
IS RECORD ( activity_metric_fact_id      number,
        last_update_date             date,
        last_updated_by              number,
        creation_date                date,
            created_by                   number,
            last_update_login            number,
            object_version_number        number,
            act_metric_used_by_id        number,
            arc_act_metric_used_by       varchar2(30),
            value_type                   varchar2(30),
            activity_metric_id           number,
            activity_geo_area_id         number,
            activity_product_id          number,
            transaction_currency_code    varchar2(15),
            trans_forecasted_value       number,
            base_quantity                number,
            functional_currency_code     varchar2(15),
            func_forecasted_value        number,
            org_id                       number,
            de_metric_id                 number,
            de_geographic_area_id        number,
            de_geographic_area_type      varchar2(30),
            de_inventory_item_id         number,
            de_inventory_item_org_id     number,
            time_id1                     number,
            time_id2                     number,
            time_id3                     number,
            time_id4                     number,
            time_id5                     number,
            time_id6                     number,
            time_id7                     number,
            time_id8                     number,
            time_id9                     number,
            time_id10                    number,
            time_id11                    number,
            time_id12                    number,
            time_id13                    number,
            time_id14                    number,
            time_id15                    number,
            time_id16                    number,
            time_id17                    number,
            time_id18                    number,
            time_id19                    number,
            time_id20                    number,
            time_id21                    number,
            time_id22                    number,
            time_id23                    number,
            time_id24                    number,
            time_id25                    number,
            time_id26                    number,
            time_id27                    number,
            time_id28                    number,
            time_id29                    number,
            time_id30                    number,
            time_id31                    number,
            time_id32                    number,
            time_id33                    number,
            time_id34                    number,
            time_id35                    number,
            time_id36                    number,
            time_id37                    number,
            time_id38                    number,
            time_id39                    number,
            time_id40                    number,
            time_id41                    number,
            time_id42                    number,
            time_id43                    number,
            time_id44                    number,
            time_id45                    number,
            time_id46                    number,
            time_id47                    number,
            time_id48                    number,
            time_id49                    number,
            time_id50                    number,
            time_id51                    number,
            time_id52                    number,
            time_id53                    number,
            hierarchy_id                 number,
            node_id                      number,
            level_depth                  number,
            formula_id                   number,
            from_date                    date,
            to_date                      date,
            fact_value                   number,
            fact_percent                 number,
            root_fact_id                 number,
            previous_fact_id             number,
            fact_type                    varchar2(30),
            fact_reference               varchar2(240),
	        forward_buy_quantity         number,
            /* 05/21/2002 yzhao: add 10 new columns for top-down bottom-up budgeting */
            status_code                  VARCHAR2(30),
            hierarchy_type               VARCHAR2(30),
            approval_date                DATE,
            recommend_total_amount       NUMBER,
            recommend_hb_amount          NUMBER,
            request_total_amount         NUMBER,
            request_hb_amount            NUMBER,
            actual_total_amount          NUMBER,
            actual_hb_amount             NUMBER,
            base_total_pct               NUMBER,
            base_hb_pct                  NUMBER
            /* 05/21/2002 yzhao: add ends */
            );
--
-- End AMS_ACT_METRIC_FACTS_ALL
--
--
-- End of comments.


-- Start of comments
-- API Name       Init_ActMetricFact_Rec
-- Type           Private
-- Function       This Process initialize Activity Metric Fact record
-- Parameters
--    OUT NOCOPY         x_fact_rec           OUT NOCOPY act_metric_rec_fact_type
-- History
--    05/30/2002  created by Ying Zhao
-- End of comments

PROCEDURE Init_ActMetricFact_Rec(
   x_fact_rec        OUT NOCOPY act_metric_fact_rec_type
);


-- Start of comments
-- API Name       Create_ActMetricFact
-- Type           Private
-- Pre-reqs       None.
-- Function       Creates a Result associated with an Activity Metric.
--                If The Metric is associated with a Hierarchy then the
--                Node is also recorded.
-- Parameters
--    IN          p_api_version               IN NUMBER     Required
--                p_init_msg_list             IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                    IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_validation_level          IN NUMBER     Optional
--                       Default := FND_API.G_VALID_LEVEL_FULL
--                p_act_metric_fact_rec       IN act_metric_fact_rec_type  Required
--    OUT NOCOPY         x_return_status             OUT NOCOPY VARCHAR2
--                x_msg_count                 OUT NOCOPY NUMBER
--                x_msg_data                  OUT NOCOPY VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments


PROCEDURE Create_ActMetricFact (
   p_api_version                IN     NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_act_metric_fact_rec        IN  act_metric_fact_rec_type,
   x_activity_metric_fact_id    OUT NOCOPY NUMBER
);



-- Start of comments
-- API Name       Update_ActMetricFact
-- Type           Private
-- Pre-reqs       None.
-- Function       Updates the Result associated with a Node for
--                The Activity Metric.
-- Parameters
--    IN          p_api_version               IN NUMBER     Required
--                p_init_msg_list             IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                    IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_validation_level          IN NUMBER     Optional
--                       Default := FND_API.G_VALID_LEVEL_FULL
--                p_act_metric_fact_rec       IN act_metric_fact_rec_type Required
--    OUT NOCOPY         x_return_status             OUT NOCOPY VARCHAR2
--                x_msg_count                 OUT NOCOPY NUMBER
--                x_msg_data                  OUT NOCOPY VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Update_ActMetricFact (
   p_api_version                IN     NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_act_metric_fact_rec        IN     act_metric_fact_rec_type
);

-- Start of comments
-- API Name       Delete_ActMetricFact
-- Type           Private
-- Pre-reqs       None.
-- Function       Deletes the Result associated with a node
--                associated with an Activity Metric.
-- Parameters
--    IN          p_api_version               IN NUMBER     Required
--                p_init_msg_list             IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                    IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_activity_metric_fact_id   IN NUMBER  Required
--                p_object_version_number     IN NUMBER
--    OUT NOCOPY         x_return_status             OUT NOCOPY VARCHAR2
--                x_msg_count                 OUT NOCOPY NUMBER
--                x_msg_data                  OUT NOCOPY VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Delete_ActMetricFact (
   p_api_version              IN  NUMBER,
   p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                   IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status            OUT NOCOPY VARCHAR2,
   x_msg_count                OUT NOCOPY NUMBER,
   x_msg_data                 OUT NOCOPY VARCHAR2,

   p_activity_metric_fact_id  IN  NUMBER DEFAULT NULL,
   p_activity_metric_id       IN  NUMBER DEFAULT NULL,
   p_object_version_number    IN  NUMBER DEFAULT NULL
);

-- Start of comments
-- API Name       Lock_ActMetricFact
-- Type           Private
-- Pre-reqs       None.
-- Function       Lock the given row in AMS_ACT_METRIC_FACTS_ALL.
-- Parameters
--    IN          p_api_version             IN NUMBER     Required
--                p_init_msg_list           IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                  IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_activity_metric_fact_id IN NUMBER  Required
--          p_object_version_number   IN NUMBER     Required
--    OUT NOCOPY         x_return_status           OUT NOCOPY VARCHAR2
--                x_msg_count               OUT NOCOPY NUMBER
--                x_msg_data                OUT NOCOPY VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments


PROCEDURE Lock_ActMetricFact (
   p_api_version             IN  NUMBER,
   p_init_msg_list           IN  VARCHAR2 := FND_API.G_FALSE,

   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count               OUT NOCOPY NUMBER,
   x_msg_data                OUT NOCOPY VARCHAR2,

   p_activity_metric_fact_id IN  NUMBER,
   p_object_version_number   IN  NUMBER
);

-- Start of comments
-- API Name       Validate_ActMetFact
-- Type           Private
-- Pre-reqs       None.
-- Function       Validate items in metric fact table associated with
--                an Activity Metric.
-- Parameters
--    IN          p_api_version           IN NUMBER     Required
--                p_init_msg_list         IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_validation_level      IN NUMBER     Optional
--                       Default := FND_API.G_VALID_LEVEL_FULL
--                p_act_metric_fact_rec   IN act_metric_fact_rec_type  Required
--    OUT NOCOPY         x_return_status         OUT NOCOPY VARCHAR2
--                x_msg_count             OUT NOCOPY NUMBER
--                x_msg_data              OUT NOCOPY VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments


PROCEDURE Validate_ActMetFact (
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,

   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2,

   p_act_metric_fact_rec        IN  act_metric_fact_rec_type
);


-- Start of comments
-- API Name       Validate_ActMetFact_Items
-- Type           Private
-- Pre-reqs       None.
-- Function       Validate Activity Metric Fact Items
-- Parameters
--    IN          p_act_metric_fact_rec    IN act_metric_fact_rec_type  Required
--                p_validate_mode        IN VARCHAR2
--    OUT NOCOPY         x_return_status          OUT NOCOPY VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Validate_ActMetFact_items(
   p_act_metric_fact_rec IN  act_metric_fact_rec_type,
   p_validation_mode     IN  VARCHAR2 := JTF_PLSQL_API.g_create,
   x_return_status       OUT NOCOPY VARCHAR2
) ;

-- Start of comments
-- API Name       Validate_ActMetFact_Rec
-- Type           Private
-- Pre-reqs       None.
-- Function       Validate Activity Metric Fact Records
-- Parameters
--    IN          p_act_metric_fact_rec   IN act_metric_fact_rec_type  Required
--                p_complete_fact_rec       IN act_metric_fact_rec_type  Required
--    OUT NOCOPY         x_return_status         OUT NOCOPY VARCHAR2
-- Version        Current version:  1.0
--                Previous version: 1.0
--                Initial version:  1.0
-- End of comments

PROCEDURE Validate_ActMetFact_Rec(
   p_act_metric_fact_rec   IN  act_metric_fact_rec_type,
   p_complete_fact_rec     IN  act_metric_fact_rec_type,
   x_return_status    OUT NOCOPY VARCHAR2
) ;


-- Start of comments
-- API Name       Complete_ActMetFact_Rec
-- Type           Private
-- Pre-reqs       None.
-- Function       This Process returns the details for the Activity Metric Fact
--
-- Parameters
--    IN          p_act_metric_fact_rec         IN  act_metric_rec_fact_type  Required
--    OUT NOCOPY         x_complete_fact_rec           OUT NOCOPY act_metric_rec_fact_type
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Complete_ActMetFact_Rec(
   p_act_metric_fact_rec      IN  act_metric_fact_rec_type,
   x_complete_fact_rec        OUT NOCOPY act_metric_fact_rec_type
);

-- Start of comments
-- API Name       Validate_FUND_Facts
-- Type           Private
-- Pre-reqs       None.
-- Function       Validate Activity Metric Fact for a act metric used by funds allocation. For each node:
--      Sum(this node and its sibling's allocation amount) <= parent allocation amount - holdback amount
--      Sum(child allocation amount) <= this node's allocation amount - holdback amount
-- Parameters
--    IN          p_act_metric_id          IN  NUMBER  Required
--    OUT NOCOPY         x_return_status          OUT NOCOPY VARCHAR2
-- End of comments

PROCEDURE Validate_FUND_Facts(
   p_api_version                IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN  NUMBER   := FND_API.G_Valid_Level_Full,
   p_act_metric_id              IN  NUMBER,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
) ;

END Ams_Actmetricfact_Pvt;

 

/
