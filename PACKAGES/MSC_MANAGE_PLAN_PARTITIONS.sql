--------------------------------------------------------
--  DDL for Package MSC_MANAGE_PLAN_PARTITIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_MANAGE_PLAN_PARTITIONS" AUTHID CURRENT_USER AS
/* $Header: MSCPRPRS.pls 120.2.12010000.1 2008/05/02 19:06:48 appldev ship $ */

   G_SUCCESS    CONSTANT NUMBER := 0;
   G_WARNING    CONSTANT NUMBER := 1;
   G_ERROR	CONSTANT NUMBER := 2;

   SYS_YES      CONSTANT NUMBER := 1;
   SYS_NO       CONSTANT NUMBER := 2;

--
-- Called by Create Plan UI. This procedure will identify if there
-- is a free partition available in MSC_PLAN_PARTITIONS. If yes then
-- it returns the plan_id. Otherwise it create a new partition by
-- performing DDL on all the partitioned tables. It stores the new
-- plan_id in MSC_PLAN_PARTITIONS, marks it as being used and returns it
-- to the calling UI
-- Return Status:
--       Success: FND_API.G_RET_STS_SUCCESS
--       failure: FND_API.G_RET_STS_ERROR (x_msg_data contains error message)
-- 		  FND_API.G_RET_STS_UNEXP_ERROR (unexpected error. x_msg_data
--						 empty
-- Note: P_plan_name has to be unique in MSC_PLAN_PARTITIONS
--

FUNCTION get_plan  (P_plan_name IN VARCHAR2,
		    x_return_status OUT NOCOPY VARCHAR2,
		    x_msg_data  OUT NOCOPY VARCHAR2) RETURN NUMBER;



--
-- This function returns a free instance
--
FUNCTION get_instance (
		    x_return_status OUT NOCOPY VARCHAR2,
		    x_msg_data  OUT NOCOPY VARCHAR2) RETURN NUMBER;

--
-- This function returns the partition name which stores the plan/instance
-- in the input table. p_is_plan = SYS_YES if partition belongs to a plan
-- otherwise it should be SYS_NO
--
-- Return Status:
--    Success: FND_API.G_RET_STS_SUCCESS
--    failure: FND_API.G_RET_STS_ERROR (x_msg_data contains error message)
-- 	  FND_API.G_RET_STS_UNEXP_ERROR (unexpected error. x_msg_data empty)


PROCEDURE get_partition_name (P_plan_id IN NUMBER,
			      P_instance_id IN NUMBER,
			     P_table_name IN VARCHAR2,
			     P_is_plan  IN NUMBER,
		             P_partition_name OUT NOCOPY VARCHAR2,
			     x_return_status OUT NOCOPY VARCHAR2,
			     x_msg_data  OUT NOCOPY VARCHAR2);

--
-- creates partitions for instances
-- called before creating plans because of the HIGHVALUE bug in
-- ST code
PROCEDURE create_inst_partition( errbuf OUT NOCOPY VARCHAR2,
				 retcode OUT NOCOPY NUMBER,
				 instance_count IN NUMBER);
--
-- truncates partition for the input plan_id
--
-- Return Status:
--    Success: FND_API.G_RET_STS_SUCCESS
--    failure: FND_API.G_RET_STS_ERROR (x_msg_data contains error message)
-- 	  FND_API.G_RET_STS_UNEXP_ERROR (unexpected error. x_msg_data empty)

PROCEDURE purge_partition( P_plan_id IN NUMBER,
		   	  x_return_status OUT NOCOPY VARCHAR2,
		    	  x_msg_data  OUT NOCOPY VARCHAR2) ;

--
-- creates partition by force. called from a concurrent program
--
PROCEDURE create_force_partition(errbuf OUT NOCOPY  VARCHAR2,
				 retcode OUT NOCOPY NUMBER,
				 partition_num IN number,
				 plan IN NUMBER := SYS_YES);

--
-- drops partition by force. called from a concurrent program
--
PROCEDURE drop_force_partition(errbuf OUT NOCOPY  VARCHAR2,
				 retcode OUT NOCOPY NUMBER,
				 partition_num IN number,
			         plan IN NUMBER := SYS_YES);



--
-- create partitions for existing plans. used when upgrading a database
--
PROCEDURE create_exist_plan_partitions(errbuf OUT NOCOPY VARCHAR2,
					 retcode OUT NOCOPY NUMBER);
--
-- drop partitions for existing plans. used to clean an unknown state
-- because of errors when creating partitions
--
PROCEDURE drop_exist_plan_partitions(errbuf OUT NOCOPY VARCHAR2,
					 retcode OUT NOCOPY NUMBER);

--
-- creates partitions for existing instances
-- called before creating plans because of the HIGHVALUE bug in
-- ST code
PROCEDURE create_exist_inst_partitions( errbuf OUT NOCOPY VARCHAR2,
				 retcode OUT NOCOPY NUMBER);

FUNCTION  get_partition_number(errbuf OUT NOCOPY VARCHAR2,
			 	retcode OUT NOCOPY NUMBER,
				x_plan_id IN NUMBER) RETURN NUMBER;
--
-- analyzes the new plan to maintain good CBO statistics
--
PROCEDURE analyze_plan(errbuf OUT NOCOPY VARCHAR2,
                                retcode OUT NOCOPY NUMBER,
                                x_plan_id IN NUMBER);

--
-- create partitions statically. to be called by the dba
--
PROCEDURE create_partitions(errbuf OUT NOCOPY VARCHAR2,
                                retcode OUT NOCOPY NUMBER,
				plan_partition_count IN NUMBER,
				inst_partition_count IN NUMBER);

END MSC_MANAGE_PLAN_PARTITIONS;

/
