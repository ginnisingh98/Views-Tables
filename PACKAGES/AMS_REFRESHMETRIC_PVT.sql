--------------------------------------------------------
--  DDL for Package AMS_REFRESHMETRIC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_REFRESHMETRIC_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvmrss.pls 115.25 2002/11/12 23:42:14 jieli ship $ */

--
-- Start of comments.
--
-- NAME
--   Ams_RefreshMetric_Pvt
--
-- PURPOSE
--   This package is a private package used to refresh Metrics
--	 It will recalculate the value of the Metric and Update the Activity Metric as
--   well as corrosponding Usage tables with new metric values.
--   This Also contains code to create Seeded Metrics from Templates defined.
--   This Package also takes care of Apportioning .
--
--   Procedures:
--   Refresh_Metric
--   Update_ActMetric
--   Lock_ActMetric
--   Delete_ActMetric
--   Validate_ActMetric
--
-- NOTES
--
--
-- HISTORY
-- 10/20/1999   ptendulk	   Created
-- 10/11/2000	sveerave	   Commented convert_currency.
-- 08/21/2001  dmvincen    Added refresh_metric with object parameters.
-- 08/21/2001  dmvincen    Added check_object_status for canceled.
--
-- 15-Jan-2002   huili        Added the "p_update_history" to the
--                            "Refresh_Act_metrics" module.
-- End of comments.
--

-- Start of comments
-- API Name       Refresh_Metric
-- Type           Private
-- Pre-reqs       None.
-- Function       Re-calculate the value for a given activity metric.
-- Parameters
--    IN          p_api_version               IN NUMBER     Required
--                p_init_msg_list             IN VARCHAR2   Optional
--                Default := FND_API.G_FALSE
--                p_commit                    IN VARCHAR2   Optional
--                 Default := FND_API.G_FALSE
--                p_activity_metric_id        IN NUMBER  Required
--				      p_refresh_type 			    IN VARCHAR2 Required
--		            p_refresh_function	       IN VARCHAR2 Optional
--    OUT         x_return_status             OUT VARCHAR2
--                x_msg_count                 OUT NUMBER
--                x_msg_data                  OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE Refresh_Metric (
   p_api_version                 IN    NUMBER,
   p_init_msg_list               IN    VARCHAR2 := Fnd_Api.G_TRUE,
   p_commit                      IN    VARCHAR2 := Fnd_Api.G_FALSE,
   x_return_status               OUT NOCOPY   VARCHAR2,
   x_msg_count                   OUT NOCOPY   NUMBER,
   x_msg_data                    OUT NOCOPY   VARCHAR2,
   p_activity_metric_id          IN    NUMBER,
   p_refresh_type                IN    VARCHAR2,
   p_refresh_function            IN   VARCHAR2 := Fnd_Api.G_TRUE
);

-- Start of Comments
--
-- NAME
--   Refresh_Act_metrics
--
-- PURPOSE
--   This procedure wrapes around Refresh_Metric and is called
--   from concurrent program
--
-- NOTES
--
--
-- HISTORY
--   05/02/1999      bgeorge    created
-- End of Comments

PROCEDURE Refresh_Act_metrics (
     errbuf        OUT NOCOPY    VARCHAR2,
     retcode       OUT NOCOPY    NUMBER,
	  p_update_history IN  VARCHAR2 := Fnd_Api.G_FALSE
);

-- Start of comments
-- API Name       GetMetricCatVal
-- Type           Private
-- Pre-reqs       None.
-- Function       --   Returns the functional forecasted value, committed value, actual
--   value depending on Return type for a given metric.
--
-- Parameters
--    IN          p_arc_act_metric_used_by       IN VARCHAR2     Required
--                p_act_metric_used_by_id        IN NUMBER       Required
--                p_metric_category              IN VARCHAR2     Required
--                p_return_type    				 IN VARCHAR2     Required
--    OUT         x_return_status         OUT VARCHAR2
--                x_value                 OUT NUMBER
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

PROCEDURE GetMetCatVal (
   x_return_status               OUT NOCOPY VARCHAR2,
   p_arc_act_metric_used_by      IN  VARCHAR2,
   p_act_metric_used_by_id       IN  NUMBER,
   p_metric_category             IN  VARCHAR2,
   p_return_type       		 IN  VARCHAR2,
   x_value        		 OUT NOCOPY NUMBER
 ) ;

-- Start of comments
-- API Name       Copy_seeded_Metric
-- Type           Private
-- Pre-reqs       None.
-- Function       This Procedure is called when a new Usage(Campaign/Event/Del.)
-- 				  is Created. This will check the templates defined for the given
--				  usage ,usage type and will copy the metrics associated with
--				  this Template to the Activity Metric.
--    			  For e.g. when Campaign c1 is created with type type1 , this
--				  process will check the template defined for campaigns (or if
--				  avilable Template for this Campaign for this campaign type )  .
--				  If Metric M1,M2,M3 are attached to Campaigns then the rows are
--				  inserted into Activity Metric table for M1,M2,M3 attached to C1
-- Parameters
--    IN          p_api_version               IN NUMBER     Required
--                p_init_msg_list             IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                    IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_act_arc_metric_used_by    IN VARCHAR2   Required
--				  p_act_metric_used_by_id 	  IN NUMBER		Required
--                p_act_metric_used_by_type   IN VARCHAR2   Required
--    OUT         x_return_status             OUT VARCHAR2
--                x_msg_count                 OUT NUMBER
--                x_msg_data                  OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments


PROCEDURE Copy_Seeded_Metric (
   p_api_version           	 IN  NUMBER,
   p_init_msg_list         	 IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                	 IN  VARCHAR2 := Fnd_Api.G_FALSE,
   x_return_status         	 OUT NOCOPY VARCHAR2,
   x_msg_count             	 OUT NOCOPY NUMBER,
   x_msg_data              	 OUT NOCOPY VARCHAR2,
   p_arc_act_metric_used_by	 IN  VARCHAR2 ,
   p_act_metric_used_by_id 	 IN  NUMBER ,
   p_act_metric_used_by_type IN  VARCHAR2
);

-- Start of comments
-- API Name       Create_Apport_Metric
-- Type           Private
-- Pre-reqs       None.
-- Function       This Procedure is called when a new Object association
-- 				  is created.This will create Activity Metric in AMS_ACT_METRICS_ALL
--				  with the details of the association.
--
-- Parameters
--    IN          p_api_version           IN NUMBER     Required
--                p_init_msg_list         IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_commit                IN VARCHAR2   Optional
--                       Default := FND_API.G_FALSE
--                p_obj_association_id    IN NUMBER  Required
--    OUT         x_return_status         OUT VARCHAR2
--                x_msg_count             OUT NUMBER
--                x_msg_data              OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments


PROCEDURE Create_Apport_Metric(
   p_api_version           	 IN  NUMBER,
   p_init_msg_list         	 IN  VARCHAR2 := Fnd_Api.G_FALSE,
   p_commit                	 IN  VARCHAR2 := Fnd_Api.G_FALSE,
   x_return_status         	 OUT NOCOPY VARCHAR2,
   x_msg_count             	 OUT NOCOPY NUMBER,
   x_msg_data              	 OUT NOCOPY VARCHAR2,
   p_obj_association_id 	 IN  NUMBER
);


-- Start of comments
-- API Name       Convert_Uom
-- Type           Private
-- Pre-reqs       None.
-- Function       This Procedure will  call the Inventory API to convert Uom
--    			  It will return the calculated quantity (in UOM of to_uom_code )
--    			  All the Calculations to calculate Value of the metrics
--    			  are done in Base Uom defined for that Metric. So the First step
--    			  before calculation starts is to convert the UOM into Base UOM.
--    			  Once the Value is calculated it's converted back to the Original
--    			  UOM Activity Metric table will be updated with this UOM
--
-- Parameters
--    IN          p_from_uom_code       		 IN VARCHAR2     Required
--		  p_to_uom_code       		 	 IN VARCHAR2     Required
--		  p_from_quantity			 IN NUMBER       Required
--                p_precision        			 IN NUMBER       Optional
--                p_from_uom_name			 IN VARCHAR2     Optional
--                p_to_uom_name				 IN VARCHAR2     Optional
--    OUT         Converted UOM quanity 		 NUMBER
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments

FUNCTION Convert_Uom(
   p_from_uom_code    	 	 	 IN  VARCHAR2,
   p_to_uom_code    	 	 	 IN  VARCHAR2,
   p_from_quantity				 IN	 NUMBER,
   p_precision					 IN	 NUMBER   DEFAULT NULL,
   p_from_uom_name				 IN  VARCHAR2 DEFAULT NULL,
   p_to_uom_name			 	 IN  VARCHAR2 DEFAULT NULL
) RETURN NUMBER ;


-- API Name       Refresh_Metric
-- Type           Private
-- Pre-reqs       None.
-- Function       Re-calculate the value for a given activity metric.
-- Parameters
--    IN          p_api_version               IN NUMBER     Required
--                p_init_msg_list             IN VARCHAR2   Optional
--                Default := FND_API.G_FALSE
--                p_commit                    IN VARCHAR2   Optional
--                 Default := FND_API.G_FALSE
--                p_arc_act_metric_used_by    IN VARCHAR2  Required
--                p_act_metric_used_by_id     IN NUMBER  Required
--		            p_refresh_function	       IN VARCHAR2 Optional
--    OUT         x_return_status             OUT VARCHAR2
--                x_msg_count                 OUT NUMBER
--                x_msg_data                  OUT VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
PROCEDURE Refresh_Metric (
   p_api_version                 IN     NUMBER,
   p_init_msg_list               IN     VARCHAR2 := Fnd_Api.G_TRUE,
   p_commit                      IN     VARCHAR2 := Fnd_Api.G_FALSE,
   x_return_status               OUT NOCOPY    VARCHAR2,
   x_msg_count                   OUT NOCOPY    NUMBER,
   x_msg_data                    OUT NOCOPY    VARCHAR2,
   p_arc_act_metric_used_by      IN     VARCHAR2,
	p_act_metric_used_by_id       IN     NUMBER,
   p_refresh_function            IN     VARCHAR2 := Fnd_Api.G_TRUE
);

-- API Name       check_object_status
-- Type           Private
-- Pre-reqs       None.
-- Function       Check if the object has been canceled.
--
-- Parameters
--    IN          p_activity_metric_id    		 IN  NUMBER       Required
--	  	  p_conv_date       		 	 IN  DATE         Required
--		  p_func_amount				 IN  NUMBER       Required
--    OUT         x_return_status			 OUT VARCHAR2
--		  x_trans_amount			 OUT NUMBER
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
PROCEDURE check_object_status(
   p_arc_act_metric_used_by IN VARCHAR2,
	p_act_metric_used_by_id IN NUMBER,
	x_is_canceled OUT NOCOPY VARCHAR2
);

END Ams_Refreshmetric_Pvt;

 

/
