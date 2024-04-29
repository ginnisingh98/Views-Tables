--------------------------------------------------------
--  DDL for Package Body DDR_WEBSERVICES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DDR_WEBSERVICES_PUB" AS
/* $Header: ddrpcwsb.pls 120.8.12010000.3 2010/03/03 04:18:48 vbhave ship $ */

 -- Start of comments
 -- API name     : get_dyn_query
 -- Type:  Private
 -- Pre-reqs: None.
 -- Function: to get the dynamic query
 -- Parameters:
 -- IN    :
 --  p_api_version         IN NUMBER Required
 --  p_mfg_org_cd          IN VARCHAR2Required
 --      Manufaturer organization code
 --  p_org_dim_lvl_cd      IN VARCHAR2
 --      Identifies the organization hierarchy level code
 --  p_org_lvl_val         IN VARCHAR2
 --      Organization hierarchy level code value
 --  p_exp_org_level       IN VARCHAR2
 --      expected aggregation level of organization hierarchy
 --  p_loc_dim_lvl_cd      IN VARCHAR2
 --      Identifies the location hierarchy level code
 --  p_loc_lvl_val         IN VARCHAR2
 --      Location hierarchy level code
 --  p_exp_loc_level       IN VARCHAR2
 --      Expected aggregation level of location hierarchy
 --  p_item_dim_lvl_cd     IN VARCHAR2
 --  p_item_lvl_val        IN VARCHAR2
 --  p_exp_item_level      IN VARCHAR2
 --  p_time_dim_lvl_cd     IN VARCHAR2
 --  p_time_lvl_val        IN VARCHAR2
 --  p_exp_time_level      IN VARCHAR2
 -- Version: Current version1.0
 --   Initial version 1.0
 -- End of comments

 PROCEDURE get_dyn_query(p_api_version     IN NUMBER,
                         p_call_type       IN VARCHAR2,
                         p_mfg_org_cd      IN VARCHAR2,
                         p_org_cd          IN VARCHAR2,
                         p_org_dim_lvl_cd  IN VARCHAR2,
                         p_org_lvl_val     IN VARCHAR2,
                         p_exp_org_level   IN VARCHAR2,
                         p_loc_dim_lvl_cd  IN VARCHAR2,
                         p_loc_lvl_val     IN VARCHAR2,
                         p_exp_loc_level   IN VARCHAR2,
                         p_item_dim_lvl_cd IN VARCHAR2,
                         p_item_lvl_val    IN VARCHAR2,
                         p_exp_item_level  IN VARCHAR2,
                         p_time_dim_lvl_cd IN VARCHAR2,
                         p_time_lvl_val    IN VARCHAR2,
                         p_exp_time_level  IN VARCHAR2,
                         p_fact_code       IN VARCHAR2,
                         x_return_status   OUT NOCOPY  VARCHAR2,
                         x_msg_count       OUT NOCOPY  NUMBER,
                         x_msg_data        OUT NOCOPY  VARCHAR2,
                         x_dyn_query       OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : get_fact_table
 -- Type:  Private
 -- Pre-reqs: None.
 -- Function: to get the name of the fact table
 -- Parameters:
 -- IN    :
 --   p_fact_code    IN VARCHAR2 Required
 --     DDR fact code
 -- OUT NOCOPY    :
 --   fact table name(VARCHAR2)
 -- Version: Current version1.0
 --   Initial version 1.0
 -- End of comments
 PROCEDURE get_fact_table(p_fact_code     IN  VARCHAR2,
                          x_return_status OUT NOCOPY  VARCHAR2,
                          x_msg_count     OUT NOCOPY  NUMBER,
                          x_msg_data      OUT NOCOPY  VARCHAR2,
                          x_fact_name     OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : get_aggr_fact_colms
 -- Type:  Private
 -- Pre-reqs: None.
 -- Function: to get the fact columns on which aggregate function to be performed.
 -- Parameters:
 -- IN    :
 --  p_fact_code    IN VARCHAR2 Required
 --        DDR fact code
 --  OUT NOCOPY    :
 --    fact columns on which aggregate function to be performed(VARCHAR2)
 -- Version: Current version1.0
 -- Initial version 1.0
 -- End of comments
 PROCEDURE get_aggr_fact_colms(p_fact_code     IN  VARCHAR2,
                               x_return_status OUT NOCOPY  VARCHAR2,
                               x_msg_count     OUT NOCOPY  NUMBER,
                               x_msg_data      OUT NOCOPY  VARCHAR2,
                               x_fact_cols     OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : get_detail_fact_colms
 -- Type:  Private
 -- Pre-reqs: None.
 -- Function: to get the fact column names.
 -- Parameters:
 -- IN    :
 --  p_fact_code    IN VARCHAR2Required
 --         DDR fact code
 --  OUT NOCOPY       :
 --          fact columns on which aggregate function to be performed(VARCHAR2)
 -- Version: Current version1.0
 -- Initial version 1.0
 -- End of comments
 PROCEDURE get_detail_fact_colms(p_fact_code     IN VARCHAR2,
                                 x_return_status OUT NOCOPY  VARCHAR2,
                                 x_msg_count     OUT NOCOPY  NUMBER,
                                 x_msg_data      OUT NOCOPY  VARCHAR2,
                                 x_fact_cols     OUT NOCOPY VARCHAR2);

 -- Start of comments
 -- API name     : get_aggr_group_colms
 -- Type:  Private
 -- Pre-reqs: None.
 -- Function: to get the name of the columns on which group by clause to be performed
 -- Parameters:
 -- IN    :
 --   p_exp_org_level            IN VARCHAR2 Required
 --         Expected organization dimension level code passed by downstream application
 --   p_exp_loc_level            IN VARCHAR2 Required
 --         Expected location dimension level code passed by downstream application
 --   p_exp_item_level            IN VARCHAR2 Required
 --         Expected item dimension level code passed by downstream application
 --   p_exp_time_level            IN VARCHAR2 Required
 --         Expected time dimension level code passed by downstream application
 -- OUT NOCOPY       :
 --   name of the columns on which group by clause to be performed (VARCHAR2)
 -- Version: Current version1.0
 -- Initial version 1.0
 -- End of comments
 PROCEDURE get_aggr_group_colms(p_exp_org_level  IN  VARCHAR2,
                                p_exp_loc_level  IN  VARCHAR2,
                                p_exp_item_level IN  VARCHAR2,
                                p_exp_time_level IN  VARCHAR2,
                                x_return_status  OUT NOCOPY  VARCHAR2,
                                x_msg_count      OUT NOCOPY  NUMBER,
                                x_msg_data       OUT NOCOPY  VARCHAR2,
                                x_group_col      OUT NOCOPY VARCHAR2);

 -- Start of comments
 -- API name     : write_fact_to_xml_file
 -- Type:  Private
 -- Pre-reqs: None.
 -- Function: to write the selected fact data to the xml file
 -- Parameters:
 -- IN    :
 --   p_query
 --        dynamic query to fetch the data
 --   p_fact_code
 --        Fact code
 --  OUT NOCOPY       :
 --   p_job_id
 --	   Job Id
 -- Version: Current version1.0
 --   Initial version 1.0
 -- End of comments
 PROCEDURE write_fact_to_xml_file(p_query         IN VARCHAR2,
                                  p_fact_code     IN VARCHAR2,
								  p_job_id        IN  NUMBER,
                                  x_return_status OUT NOCOPY  VARCHAR2,
                                  x_msg_count     OUT NOCOPY  NUMBER,
                                  x_msg_data      OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : validate_input_params
 -- Type:  Private
 -- Pre-reqs: None.
 -- Function: to validate the input parameters
 -- Parameters:
 -- IN    :
 --   p_api_version            IN NUMBER Required
 --   p_mfg_org_cd             IN VARCHAR2 Required
 --           Manufaturer organization code
 --   p_org_dim_lvl_cd         IN VARCHAR2
 --           Identifies the organization hierarchy level code
 --   p_org_lvl_val            IN VARCHAR2
 --           Organization hierarchy level code value
 --   p_exp_org_level          IN VARCHAR2
 --           expected aggregation level of organization hierarchy
 --   p_loc_dim_lvl_cd         IN VARCHAR2
 --           Identifies the location hierarchy level code
 --   p_loc_lvl_val            IN VARCHAR2
 --           Location hierarchy level code
 --   p_exp_loc_level          IN VARCHAR2
 --           Expected aggregation level of location hierarchy
 --   p_item_dim_lvl_cd        IN VARCHAR2
 --   p_item_lvl_val           IN VARCHAR2
 --   p_exp_item_level         IN VARCHAR2
 --   p_time_dim_lvl_cd        IN VARCHAR2
 --   p_time_lvl_val           IN VARCHAR2
 --   p_exp_time_level         IN VARCHAR2
 --   p_fact_code              IN VARCHAR2
 --   p_attribute1             IN VARCHAR2
 --   p_attribute2             IN VARCHAR2
 --   p_attribute3             IN VARCHAR2
 --   p_attribute4             IN VARCHAR2
 --   p_attribute5             IN VARCHAR2values are ''A' for Aggregate and ''D'' for detail
 --  OUT NOCOPY       :
 --     fact table name(VARCHAR2)
 -- Version: Current version1.0
 -- Initial version 1.0
 -- End of comments

 PROCEDURE validate_input_params(p_api_version     IN  NUMBER,
                                 p_mfg_org_cd      IN  VARCHAR2,
                                 p_org_cd          IN  VARCHAR2,
                                 p_org_dim_lvl_cd  IN  VARCHAR2,
                                 p_org_lvl_val     IN  VARCHAR2,
                                 p_exp_org_level   IN  VARCHAR2,
                                 p_loc_dim_lvl_cd  IN  VARCHAR2,
                                 p_loc_lvl_val     IN  VARCHAR2,
                                 p_exp_loc_level   IN  VARCHAR2,
                                 p_item_dim_lvl_cd IN  VARCHAR2,
                                 p_item_lvl_val    IN  VARCHAR2,
                                 p_exp_item_level  IN  VARCHAR2,
                                 p_time_dim_lvl_cd IN  VARCHAR2,
                                 p_time_lvl_val    IN  VARCHAR2,
                                 p_exp_time_level  IN  VARCHAR2,
                                 p_fact_code       IN  VARCHAR2,
                                 x_return_status   OUT NOCOPY  VARCHAR2,
                                 x_msg_count       OUT NOCOPY  NUMBER,
                                 x_msg_data        OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : get_ddr_ws_file_seq_nextval
 -- Type:  Private
 -- Pre-reqs: None.
 -- Function: to get the file id from sequence
 -- Parameters:
 -- IN   :
 --
 -- OUT NOCOPY   :
 --     file ID sequence number
 -- Version: Current version1.0
 -- Initial version 1.0
 -- End of comments
 FUNCTION get_ddr_ws_file_seq_nextval(x_return_status OUT NOCOPY  VARCHAR2,
                                      x_msg_count     OUT NOCOPY  NUMBER,
                                      x_msg_data      OUT NOCOPY  VARCHAR2) RETURN VARCHAR2;


 -- Start of comments
 -- API name     : get_itm_hrchy_clauses
 -- Type:  Private
 -- Pre-reqs: None.
 -- Function: to get the item hierarchy clauses
 -- Parameters:
 -- IN    :
 --   p_item_dim_lvl_cd
 --         item dimensions hiertarchy level code
 --   p_item_lvl_val
 --         item dimension hierarchy level code value
 -- OUT NOCOPY    :
 --
 -- Version: Current version1.0
 --   Initial version 1.0
 -- End of comments
 PROCEDURE get_itm_hrchy_clauses(p_item_dim_lvl_cd IN  VARCHAR2,
                                 p_item_lvl_val    IN  VARCHAR2,
                                 p_exp_item_level  IN  VARCHAR2,
                                 p_fact_code       IN  VARCHAR2,
                                 x_return_status   OUT NOCOPY  VARCHAR2,
                                 x_msg_count       OUT NOCOPY  VARCHAR2,
                                 x_msg_data        OUT NOCOPY  VARCHAR2,
                                 x_itm_ref_tbls    OUT NOCOPY  VARCHAR2,
                                 x_itm_ref_joins   OUT NOCOPY  VARCHAR2,
                                 x_itm_where_clus  OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : get_item_ref_join
 -- Type:  Private
 -- Pre-reqs: None.
 -- Function: to get the reference joiins for the item hierarchy
 -- Parameters:
 -- IN    :
 --               p_sys_var
 -- system variable name
 --  OUT NOCOPY       :
 -- '
 -- Version: Current version1.0
 --   Initial version 1.0
 -- End of comments
 PROCEDURE get_item_ref_join(p_lvl_rnk         IN  NUMBER,
                             x_ref_join        OUT NOCOPY  VARCHAR2,
                             x_return_status   OUT NOCOPY  VARCHAR2,
                             x_msg_count       OUT NOCOPY  VARCHAR2,
                             x_msg_data        OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : get_org_hrchy_clauses
 -- Type:  Private
 -- Pre-reqs: None.
 -- Function: to get the organization hierarchy clauses
 -- Parameters:
 -- IN    :
 --               p_sys_var
 -- system variable name
 --  OUT NOCOPY       :
 -- '
 -- Version: Current version1.0
 --   Initial version 1.0
 -- End of comments
 PROCEDURE get_org_hrchy_clauses(p_org_dim_lvl_cd  IN  VARCHAR2,
                                 p_org_lvl_val     IN  VARCHAR2,
                                 p_exp_org_level   IN  VARCHAR2,
                                 p_fact_code       IN  VARCHAR2,
                                 x_return_status   OUT NOCOPY  VARCHAR2,
                                 x_msg_count       OUT NOCOPY  VARCHAR2,
                                 x_msg_data        OUT NOCOPY  VARCHAR2,
                                 x_org_ref_tbls    OUT NOCOPY  VARCHAR2,
                                 x_org_ref_joins   OUT NOCOPY  VARCHAR2,
                                 x_org_where_clus  OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : get_org_ref_join
 -- Type:  Private
 -- Pre-reqs: None.
 -- Function: to get the reference joiins for the organization hierarchy
 -- Parameters:
 -- IN    :
 --               p_sys_var
 -- system variable name
 --  OUT NOCOPY       :
 -- '
 -- Version: Current version1.0
 --   Initial version 1.0
 PROCEDURE get_org_ref_join(p_lvl_rnk         IN  NUMBER,
                            x_ref_join        OUT NOCOPY  VARCHAR2,
                            x_return_status   OUT NOCOPY  VARCHAR2,
                            x_msg_count       OUT NOCOPY  VARCHAR2,
                            x_msg_data        OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : get_itm_hrchy_clauses
 -- Type:  Private
 -- Pre-reqs: None.
 -- Function: to get the time hierarchy clauses
 -- Parameters:
 -- IN    :
 --               p_sys_var
 -- system variable name
 --  OUT NOCOPY       :
 -- '
 -- Version: Current version1.0
 --   Initial version 1.0
 -- End of comments
 PROCEDURE get_time_hrchy_clauses(p_time_dim_lvl_cd IN  VARCHAR2,
                                  p_time_lvl_val    IN  VARCHAR2,
                                  p_exp_time_level  IN  VARCHAR2,
                                  p_fact_code       IN  VARCHAR2,
                                  p_org_cd          IN  VARCHAR2,
                                  x_return_status   OUT NOCOPY  VARCHAR2,
                                  x_msg_count       OUT NOCOPY  VARCHAR2,
                                  x_msg_data        OUT NOCOPY  VARCHAR2,
                                  x_time_ref_tbls   OUT NOCOPY  VARCHAR2,
                                  x_time_ref_joins  OUT NOCOPY  VARCHAR2,
                                  x_time_where_clus OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : get_time_ref_join
 -- Type:  Private
 -- Pre-reqs: None.
 -- Function: to get the reference joiins for the time hierarchy
 -- Parameters:
 -- IN    :
 --               p_sys_var
 -- system variable name
 --  OUT NOCOPY       :
 -- '
 -- Version: Current version1.0
 --   Initial version 1.0
 PROCEDURE get_time_ref_join(p_hrchy_name      IN  VARCHAR2,
                             p_lvl_rnk         IN  NUMBER,
                             x_ref_join        OUT NOCOPY  VARCHAR2,
                             x_return_status   OUT NOCOPY  VARCHAR2,
                             x_msg_count       OUT NOCOPY  VARCHAR2,
                             x_msg_data        OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : get_itm_hrchy_clauses
 -- Type:  Private
 -- Pre-reqs: None.
 -- Function: to get the location hierarchy clauses
 -- Parameters:
 -- IN    :
 --               p_sys_var
 -- system variable name
 --  OUT NOCOPY       :
 -- '
 -- Version: Current version1.0
 --   Initial version 1.0
 -- End of comments
 PROCEDURE get_loc_hrchy_clauses(p_loc_dim_lvl_cd  IN  VARCHAR2,
                                 p_loc_lvl_val     IN  VARCHAR2,
                                 p_exp_loc_level   IN  VARCHAR2,
                                 p_org_dim_lvl_cd  IN  VARCHAR2,
                                 p_fact_code       IN  VARCHAR2,
                                 x_return_status   OUT NOCOPY  VARCHAR2,
                                 x_msg_count       OUT NOCOPY  VARCHAR2,
                                 x_msg_data        OUT NOCOPY  VARCHAR2,
   x_loc_ref_tbls    OUT NOCOPY  VARCHAR2,
   x_loc_ref_joins   OUT NOCOPY  VARCHAR2,
   x_loc_where_clus  OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : get_loc_ref_join
 -- Type:  Private
 -- Pre-reqs: None.
 -- Function: to get the reference joiins for the location hierarchy
 -- Parameters:
 -- IN    :
 --               p_sys_var
 -- system variable name
 --  OUT NOCOPY       :
 -- '
 -- Version: Current version1.0
 --   Initial version 1.0
 PROCEDURE get_loc_ref_join(p_lvl_rnk         IN NUMBER,
                            x_ref_join        OUT NOCOPY  VARCHAR2,
                            x_return_status   OUT NOCOPY  VARCHAR2,
                            x_msg_count       OUT NOCOPY  VARCHAR2,
                            x_msg_data        OUT NOCOPY  VARCHAR2);

 -- Start of comments
 -- API name     : get_hrchy_lvl
 -- Type:  Private
 -- Pre-reqs: None.
 -- Function: to get the hierarchy level for the given hierarchy code from metadata table
 -- Parameters:
 -- IN    :
 --               p_sys_var
 -- system variable name
 --  OUT NOCOPY       :
 -- '
 -- Version: Current version1.0
 --   Initial version 1.0
 PROCEDURE get_hrchy_lvl(p_hrchy_lvl_name  IN VARCHAR2,
                         p_hrchy_lvl_cd    IN VARCHAR2,
                         x_hrchy_lvl       OUT NOCOPY  NUMBER,
                         x_return_status   OUT NOCOPY  VARCHAR2,
                         x_msg_count       OUT NOCOPY  VARCHAR2,
                         x_msg_data        OUT NOCOPY  VARCHAR2);
 --Bug 6880404 change start
 --Start of comments
 -- API name     : get_other_join_conditions
 -- Type:  Private
 -- Pre-reqs: None.
 -- Function: to get any other join conditions related
 -- Parameters:
 -- IN    :
 --               p_sys_var
 -- system variable name
 --  OUT NOCOPY       :
 -- '
 -- Version: Current version1.0
 --   Initial version 1.0
 PROCEDURE get_other_join_conditions(p_fact_code       IN VARCHAR2,
                                     x_return_status   OUT NOCOPY  VARCHAR2,
                                     x_msg_count       OUT NOCOPY  VARCHAR2,
                                     x_msg_data        OUT NOCOPY  VARCHAR2,
                                     x_oth_join_codn   OUT NOCOPY  VARCHAR2);
 --Bug 6880404 change end

 PROCEDURE ddr_fact_aggr_prc(p_api_version      IN  NUMBER,
                             p_job_id           IN  NUMBER,
                             p_mfg_org_cd       IN  VARCHAR2,
                             p_org_cd           IN  VARCHAR2,
                             p_org_dim_lvl_cd   IN  VARCHAR2,
                             p_org_lvl_val      IN  VARCHAR2,
                             p_exp_org_level    IN  VARCHAR2,
                             p_loc_dim_lvl_cd   IN  VARCHAR2,
                             p_loc_lvl_val      IN  VARCHAR2,
                             p_exp_loc_level    IN  VARCHAR2,
                             p_item_dim_lvl_cd  IN  VARCHAR2,
                             p_item_lvl_val     IN  VARCHAR2,
                             p_exp_item_level   IN  VARCHAR2,
                             p_time_dim_lvl_cd  IN  VARCHAR2,
                             p_time_lvl_val     IN  VARCHAR2,
                             p_exp_time_level   IN  VARCHAR2,
                             p_fact_code        IN  VARCHAR2,
                             p_attribute1       IN  VARCHAR2,
                             p_attribute2       IN  VARCHAR2,
                             p_attribute3       IN  VARCHAR2,
                             p_attribute4       IN  VARCHAR2,
                             p_attribute5       IN  VARCHAR2)
 AS
    l_query         VARCHAR2(32767):=null;
    l_return_status VARCHAR2(30):=null;
    l_msg_count     NUMBER:=null;
    l_msg_data      VARCHAR2(250):=null;
	l_job_id        NUMBER:=null;
 BEGIN
 	  l_job_id:=p_job_id;
     --update job status to Running
     UPDATE DDR_WS_JOB set status= ddr_webservices_constants.g_ret_sts_running,start_date=sysdate where job_id=p_job_id ;
     --build dynamic query
     get_dyn_query(p_api_version,
                   'A',
                   p_mfg_org_cd,
                   p_org_cd,
                   p_org_dim_lvl_cd,
                   p_org_lvl_val,
                   p_exp_org_level,
                   p_loc_dim_lvl_cd,
                   p_loc_lvl_val,
                   p_exp_loc_level,
                   p_item_dim_lvl_cd,
                   p_item_lvl_val,
                   p_exp_item_level,
                   p_time_dim_lvl_cd,
                   p_time_lvl_val,
                   p_exp_time_level,
                   p_fact_code,
                   l_return_status,
                   l_msg_count,
                   l_msg_data,
                   l_query);
     IF l_return_status<>ddr_webservices_constants.g_ret_sts_success THEN
          UPDATE DDR_WS_JOB SET status=l_return_status,err_message=l_msg_data,end_date=sysdate WHERE job_id=p_job_id ;
          RETURN;
     END IF;
     --write data to xml file based on dynamic query generated
     write_fact_to_xml_file(l_query,p_fact_code,l_job_id,l_return_status,l_msg_count,l_msg_data);
     --update job status to complete/error
     UPDATE DDR_WS_JOB SET status=ddr_webservices_constants.g_ret_sts_success,err_message=l_msg_data,end_date=sysdate WHERE job_id=p_job_id ;
 EXCEPTION
     WHEN NO_DATA_FOUND THEN
       l_return_status:=ddr_webservices_constants.g_ret_sts_error;
       l_msg_count:=1;
       l_msg_data:='No Data Found. Error code:'||sqlcode||' Error message:'||sqlerrm;
       UPDATE DDR_WS_JOB SET status=l_return_status,err_message=l_msg_data,end_date=sysdate WHERE job_id=p_job_id ;
    WHEN OTHERS THEN
       l_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
       l_msg_count:=1;
       l_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
       UPDATE DDR_WS_JOB SET status=l_return_status,err_message=l_msg_data,end_date=sysdate WHERE job_id=p_job_id ;
 END ddr_fact_aggr_prc;

 PROCEDURE ddr_fact_details_prc(p_api_version     IN  NUMBER,
                                p_job_id          IN  NUMBER,
                                p_mfg_org_cd      IN  VARCHAR2,
                                p_org_cd          IN  VARCHAR2,
                                p_org_dim_lvl_cd  IN  VARCHAR2,
                                p_org_lvl_val     IN  VARCHAR2,
                                p_loc_dim_lvl_cd  IN  VARCHAR2,
                                p_loc_lvl_val     IN  VARCHAR2,
                                p_item_dim_lvl_cd IN  VARCHAR2,
                                p_item_lvl_val    IN  VARCHAR2,
                                p_time_dim_lvl_cd IN  VARCHAR2,
                                p_time_lvl_val    IN  VARCHAR2,
                                p_fact_code       IN  VARCHAR2,
                                p_attribute1      IN  VARCHAR2,
                                p_attribute2      IN  VARCHAR2,
                                p_attribute3      IN  VARCHAR2,
                                p_attribute4      IN  VARCHAR2,
                                p_attribute5      IN  VARCHAR2)
 AS
    l_query         VARCHAR2(32767):=null;
    l_return_status VARCHAR2(30):=null;
    l_msg_count     NUMBER:=null;
    l_msg_data      VARCHAR2(250):=null;
	l_job_id        NUMBER:=null;
 BEGIN
    l_job_id:=p_job_id;
	--update job status to Running
    UPDATE DDR_WS_JOB set status= ddr_webservices_constants.g_ret_sts_running,start_date=sysdate where job_id=p_job_id ;
    --build dynamic query
    get_dyn_query(p_api_version,
                  'D',
                  p_mfg_org_cd,
                  p_org_cd,
                  p_org_dim_lvl_cd,
                  p_org_lvl_val,
                  null,
                  p_loc_dim_lvl_cd,
                  p_loc_lvl_val,
                  null,
                  p_item_dim_lvl_cd,
                  p_item_lvl_val,
                  null,
                  p_time_dim_lvl_cd,
                  p_time_lvl_val,
                  null,
                  p_fact_code,
                  l_return_status,
                  l_msg_count,
                  l_msg_data,
                  l_query);

    IF l_return_status<>ddr_webservices_constants.g_ret_sts_success THEN
        UPDATE DDR_WS_JOB SET status=l_return_status,err_message=l_msg_data,end_date=sysdate WHERE job_id=p_job_id ;
        RETURN;
    END IF;
    --write data to xml file based on dynamic query generated
    write_fact_to_xml_file(l_query,p_fact_code,l_job_id,l_return_status,l_msg_count,l_msg_data);
    --update job status to complete/error
    UPDATE DDR_WS_JOB SET status=ddr_webservices_constants.g_ret_sts_success,err_message=l_msg_data,end_date=sysdate WHERE job_id=p_job_id ;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
       l_return_status:=ddr_webservices_constants.g_ret_sts_error;
       l_msg_count:=1;
       l_msg_data:='No Data Found. Error code:'||sqlcode||' Error message:'||sqlerrm;
       UPDATE DDR_WS_JOB SET status=l_return_status,err_message=l_msg_data,end_date=sysdate WHERE job_id=p_job_id ;
    WHEN OTHERS THEN
       l_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
       l_msg_count:=1;
       l_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
       UPDATE DDR_WS_JOB SET status=l_return_status,err_message=l_msg_data,end_date=sysdate WHERE job_id=p_job_id ;
 END ddr_fact_details_prc;


 PROCEDURE get_dyn_query(p_api_version     IN NUMBER,
                         p_call_type       IN VARCHAR2,
                         p_mfg_org_cd      IN VARCHAR2,
                         p_org_cd          IN VARCHAR2,
                         p_org_dim_lvl_cd  IN VARCHAR2,
                         p_org_lvl_val     IN VARCHAR2,
                         p_exp_org_level   IN VARCHAR2,
                         p_loc_dim_lvl_cd  IN VARCHAR2,
                         p_loc_lvl_val     IN VARCHAR2,
                         p_exp_loc_level   IN VARCHAR2,
                         p_item_dim_lvl_cd IN VARCHAR2,
                         p_item_lvl_val    IN VARCHAR2,
                         p_exp_item_level  IN VARCHAR2,
                         p_time_dim_lvl_cd IN VARCHAR2,
                         p_time_lvl_val    IN VARCHAR2,
                         p_exp_time_level  IN VARCHAR2,
                         p_fact_code       IN VARCHAR2,
                         x_return_status   OUT NOCOPY  VARCHAR2,
                         x_msg_count       OUT NOCOPY  NUMBER,
                         x_msg_data        OUT NOCOPY  VARCHAR2,
                         x_dyn_query       OUT NOCOPY  VARCHAR2)
 IS
    l_query           VARCHAR2(32767):=null;
    l_fact_table_name VARCHAR2(30)   :=null;
    l_fact_cols       VARCHAR2(32767):=null;
    l_org_where_clus  VARCHAR2(100)  :=null;
    l_loc_where_clus  VARCHAR2(100)  :=null;
    l_itm_where_clus  VARCHAR2(100)  :=null;
    l_time_where_clus VARCHAR2(100)  :=null;
    l_group_col       VARCHAR2(120)  :=null;
    l_query_len       NUMBER         :=null;
    l_itm_ref_tbls    VARCHAR2(32767):=null;
    l_itm_ref_joins   VARCHAR2(32767):=null;
    l_org_ref_tbls    VARCHAR2(32767):=null;
    l_org_ref_joins   VARCHAR2(32767):=null;
    l_time_ref_tbls   VARCHAR2(32767):=null;
    l_time_ref_joins  VARCHAR2(32767):=null;
    l_loc_ref_tbls    VARCHAR2(32767):=null;
    l_loc_ref_joins   VARCHAR2(32767):=null;
    --Bug 6880404 change start
    l_oth_join_codn   VARCHAR2(32767):=null;
    --Bug 6880404 change end
 BEGIN
    --validate the input parameters
    validate_input_params(p_api_version,
                          p_mfg_org_cd,
                          p_org_cd,
                          p_org_dim_lvl_cd,
                          p_org_lvl_val,
                          null,
                          p_loc_dim_lvl_cd,
                          p_loc_lvl_val,
                          null,
                          p_item_dim_lvl_cd,
                          p_item_lvl_val,
                          null,
                          p_time_dim_lvl_cd,
                          p_time_lvl_val,
                          p_exp_time_level,
                          p_fact_code,
                          x_return_status,
                          x_msg_count,
                          x_msg_data);
    IF  x_return_status<>ddr_webservices_constants.g_ret_sts_success THEN
       RETURN;
    END IF;
    -- get fact table name
    get_fact_table(p_fact_code,x_return_status,x_msg_count,x_msg_data,l_fact_table_name);
    IF p_call_type='A' THEN
       -- get aggregated select fact column names
       get_aggr_fact_colms(p_fact_code,x_return_status,x_msg_count,x_msg_data,l_fact_cols);
    ELSIF p_call_type='D' THEN
       -- get detailed select fact column names
       get_detail_fact_colms(p_fact_code,x_return_status,x_msg_count,x_msg_data,l_fact_cols);
    END IF;
    --get the reference tables ,reference table joins and where clause for the item hierarchy
    IF  p_item_dim_lvl_cd IS NOT NULL OR p_exp_item_level IS NOT NULL THEN
               get_itm_hrchy_clauses(p_item_dim_lvl_cd,
                            p_item_lvl_val,
                            p_exp_item_level,
                            p_fact_code,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            l_itm_ref_tbls,
                            l_itm_ref_joins,
                            l_itm_where_clus);
      IF x_return_status<>ddr_webservices_constants.g_ret_sts_success THEN
          RETURN;
      END IF;
    END IF;
    --get the reference tables ,reference table joins and where clause join for the organization hierarchy level
    IF  p_org_dim_lvl_cd IS NOT NULL OR p_exp_org_level IS NOT NULL THEN
           get_org_hrchy_clauses(p_org_dim_lvl_cd,
                            p_org_lvl_val,
                            p_exp_org_level,
                            p_fact_code,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            l_org_ref_tbls,
                            l_org_ref_joins,
                            l_org_where_clus);
       IF x_return_status<>ddr_webservices_constants.g_ret_sts_success THEN
           RETURN;
       END IF;
    END IF;
    --get the reference tables ,reference table joins and where clause join for the time hierarchy level
    IF  p_time_dim_lvl_cd IS NOT NULL OR p_exp_time_level IS NOT NULL THEN
         get_time_hrchy_clauses(p_time_dim_lvl_cd,
                             p_time_lvl_val,
                             p_exp_time_level,
                             p_fact_code,
                             p_org_cd,
                             x_return_status,
                             x_msg_count,
                             x_msg_data,
                             l_time_ref_tbls,
                             l_time_ref_joins,
                             l_time_where_clus);
      IF x_return_status<>ddr_webservices_constants.g_ret_sts_success THEN
         RETURN;
      END IF;
   END IF;
   --get the reference tables ,reference table joins and where clause join for the location hierarchy level
   IF  p_loc_dim_lvl_cd IS NOT NULL OR p_exp_loc_level IS NOT NULL THEN
        get_loc_hrchy_clauses(p_loc_dim_lvl_cd,
                            p_loc_lvl_val,
                            p_exp_loc_level,
                            p_org_dim_lvl_cd,
                            p_fact_code,
                            x_return_status,
                            x_msg_count,
                            x_msg_data,
                            l_loc_ref_tbls,
                            l_loc_ref_joins,
                            l_loc_where_clus);
      IF x_return_status<>ddr_webservices_constants.g_ret_sts_success THEN
          RETURN;
      END IF;
   END IF;
   --Bug 6880404 change start
   --get other join conditions
   get_other_join_conditions(p_fact_code,
                             x_return_status,
                             x_msg_count,
                             x_msg_data,
                             l_oth_join_codn);
   --Bug 6880404 change end
   -- get group by columns
   IF p_call_type='A' THEN
     get_aggr_group_colms(p_exp_org_level,
                          p_exp_loc_level,
                          p_exp_item_level,
                          p_exp_time_level,
                          x_return_status,
                          x_msg_count,
                          x_msg_data,
                          l_group_col);
     IF x_return_status<>ddr_webservices_constants.g_ret_sts_success THEN
           RETURN;
     END IF;
   END IF;

   --dynamically building query
   l_query := 'SELECT ' || l_fact_cols;
   IF p_call_type='A' AND l_group_col IS NOT NULL THEN
     l_query := l_query || ','|| l_group_col;
   END IF;
   --appending fact table to query string
   l_query := l_query || ' FROM ' || l_fact_table_name || ' x';
   --include the various reference tables in from clause
   --Item Hierarchy reference tables
   l_query := l_query || l_itm_ref_tbls;
   --Organization Hierarchy reference tables
   l_query := l_query || l_org_ref_tbls;
   --Time Hierarchy reference tables
   l_query := l_query || l_time_ref_tbls;
   --location Hierarchy reference tables
   l_query := l_query || l_loc_ref_tbls;
   --appending  organization code to query string
   l_query := l_query || ' WHERE '|| ' x.MFG_ORG_CD ='''|| p_mfg_org_cd||'''';
   l_query := l_query || ' AND '|| ' x.RTL_ORG_CD ='''|| p_org_cd||'''';
   --Bug 6880404 change start
   l_query := l_query || l_oth_join_codn;
   --Bug 6880404 change end
   -- ITEM Dimension Hierarchy joins
   l_query := l_query || l_itm_ref_joins;
   IF l_itm_where_clus IS NOT NULL THEN
    l_query := l_query || ' AND ' ||  l_itm_where_clus || '';
   END IF;
   -- Organization Dimension Hierarchy joins
   l_query := l_query || l_org_ref_joins;
   IF l_org_where_clus IS NOT NULL THEN
     l_query := l_query || ' AND '|| l_org_where_clus || '';
   END IF;
   -- Time Dimension Hierarchy joins
    l_query := l_query || l_time_ref_joins;
   IF l_time_where_clus IS NOT NULL THEN
      l_query := l_query || '  AND '|| l_time_where_clus || '';
   END IF;
   -- Loaction Dimension Hierarchy joins
   l_query := l_query ||l_loc_ref_joins;
   IF l_loc_where_clus IS NOT NULL THEN
     l_query := l_query || '  AND '|| l_loc_where_clus || '';
   END IF;
   IF p_call_type='A' THEN
    --group by clause join
    IF l_group_col IS NOT NULL THEN
     l_query := l_query || ' GROUP BY '|| l_group_col;
    END IF;
   END IF;
   SELECT LENGTH(l_query) into l_query_len from dual;
   -- DBMS_OUTPUT.PUT_LINE('l_query_len='||l_query_len);
   -- DBMS_OUTPUT.PUT_LINE('l_query='||l_query);
   x_dyn_query:= l_query;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
        x_return_status := ddr_webservices_constants.g_ret_sts_error;
        x_msg_count := 1;
        x_msg_data := 'No Data Found. Error Code' ||sqlcode||' Error message:'||sqlerrm;
   WHEN OTHERS THEN
        x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
        x_msg_count:=1;
        x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
 END get_dyn_query;

 PROCEDURE get_fact_table(p_fact_code     IN VARCHAR2,
                          x_return_status OUT NOCOPY  VARCHAR2,
                          x_msg_count     OUT NOCOPY  NUMBER,
                          x_msg_data      OUT NOCOPY  VARCHAR2,
                          x_fact_name     OUT NOCOPY  VARCHAR2)
 IS
 BEGIN
   --case condition to determine name of the fact table
   CASE p_fact_code
   -- for MARKET ITEM SALES DAY
   WHEN ddr_webservices_constants.g_misd_cd THEN
        x_fact_name:= ddr_webservices_constants.g_misd_fact_tbl;
   -- for PROMOTION PLAN
   WHEN ddr_webservices_constants.g_pp_cd THEN
        x_fact_name:= ddr_webservices_constants.g_pp_fact_tbl;
   -- for RETAIL INVENTORY ITEM DAY
   WHEN ddr_webservices_constants.g_riid_cd THEN
        x_fact_name:= ddr_webservices_constants.g_riid_fact_tbl;
   -- for RETAIL SALE RETURN ITEM DAY fact
   WHEN ddr_webservices_constants.g_rsrid_cd THEN
        x_fact_name:= ddr_webservices_constants.g_rsrid_fact_tbl;
   -- for RETAILER ORDER ITEM DAY
   WHEN ddr_webservices_constants.g_roid_cd THEN
        x_fact_name:= ddr_webservices_constants.g_roid_fact_tbl;
   -- for RETAILER SHIP ITEM DAY
   WHEN ddr_webservices_constants.g_rsid_cd THEN
        x_fact_name:= ddr_webservices_constants.g_rsid_fact_tbl;
   -- for SALE FORECAST ITEM BY DAY
   WHEN ddr_webservices_constants.g_sfid_cd  THEN
        x_fact_name:= ddr_webservices_constants.g_sfid_fact_tbl;
   END CASE;
  EXCEPTION
    WHEN OTHERS THEN
        x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
        x_msg_count:=1;
        x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
 END get_fact_table;

 PROCEDURE get_aggr_fact_colms(p_fact_code    IN  VARCHAR2,
                              x_return_status OUT NOCOPY  VARCHAR2,
                              x_msg_count     OUT NOCOPY  NUMBER,
                              x_msg_data      OUT NOCOPY  VARCHAR2,
                              x_fact_cols     OUT NOCOPY  VARCHAR2)
 IS
 BEGIN
  --case condition to identify aggregate column names from fact table
  CASE p_fact_code
  -- for MARKET ITEM SALES DAY
  WHEN ddr_webservices_constants.g_misd_cd THEN
   x_fact_cols:='sum(x.AVG_MMACV_SLS_RATE) AVG_MMACV_SLS_RATE,'
   ||'sum(x.AVG_STORE_SELL_ITEM_QTY) AVG_STORE_SELL_ITEM_QTY,'
   ||'sum(x.AVG_ACV_WGT_DSTRBTN_PCT) AVG_ACV_WGT_DSTRBTN_PCT,'
   ||'sum(x.AVG_WGT_PRICE_RDCTN_PCT) AVG_WGT_PRICE_RDCTN_PCT,'
   ||'sum(x.SLS_QTY) SLS_QTY,'
   ||'sum(x.SLS_AMT) SLS_AMT,'
   ||'sum(x.NRML_QTY) NRML_QTY,'
   ||'sum(x.NRML_AMT) NRML_AMT,'
   ||'sum(x.SLS_PRICE_CUT_QTY) SLS_PRICE_CUT_QTY,'
   ||'sum(x.SLS_PRICE_CUT_AMT) SLS_PRICE_CUT_AMT,'
   ||'sum(x.MAIN_AD_QTY) MAIN_AD_QTY,'
   ||'sum(x.MAIN_AD_AMT) MAIN_AD_AMT';
             --for PROMOTION PLAN
 WHEN ddr_webservices_constants.g_pp_cd THEN
  x_fact_cols:='sum(x.PRMTN_PRICE_AMT) PRMTN_PRICE_AMT';
  -- for RETAIL INVENTORY ITEM DAY
 WHEN ddr_webservices_constants.g_riid_cd THEN
  x_fact_cols:= 'sum(x.ON_HAND_QTY) ON_HAND_QTY,'
  ||'sum(x.RECVD_QTY) RECVD_QTY,'
  ||'sum(x.IN_TRANSIT_QTY) IN_TRANSIT_QTY,'
  ||'sum(x.BCK_ORDR_QTY) BCK_ORDR_QTY,'
  ||'sum(x.QLTY_HOLD_QTY) QLTY_HOLD_QTY,'
  ||'sum(x.ON_HAND_NET_COST_AMT) ON_HAND_NET_COST_AMT,'
  ||'sum(x.RECVD_NET_COST_AMT) RECVD_NET_COST_AMT,'
  ||'sum(x.IN_TRANSIT_NET_COST_AMT) IN_TRANSIT_NET_COST_AMT,'
  ||'sum(x.BCKORDR_NET_COST_AMT) BCKORDR_NET_COST_AMT,'
  ||'sum(x.QLTY_HOLD_NET_COST_AMT) QLTY_HOLD_NET_COST_AMT,'
  ||'sum(x.ON_HAND_RTL_AMT) ON_HAND_RTL_AMT,'
  ||'sum(x.RECVD_RTL_AMT) RECVD_RTL_AMT,'
  ||'sum(x.IN_TRANSIT_RTL_AMT) IN_TRANSIT_RTL_AMT,'
  ||'sum(x.BCKORDR_RTL_AMT) BCKORDR_RTL_AMT,'
  ||'sum(x.QLTY_HOLD_RTL_AMT) QLTY_HOLD_RTL_AMT';
  -- for RETAIL SALE RETURN ITEM DAY fact
 WHEN ddr_webservices_constants.g_rsrid_cd THEN
  x_fact_cols:='sum(x.SLS_QTY) SLS_QTY,'
  ||'sum(x.SLS_AMT) SLS_AMT,'
  ||'sum(x.SLS_COST_AMT) SLS_COST_AMT,'
  ||'sum(x.RTRN_QTY) RTRN_QTY,'
  ||'sum(x.RTRN_AMT) RTRN_AMT,'
  ||'sum(x.RTRN_COST_AMT) RTRN_COST_AMT';
 -- for RETAILER ORDER ITEM DAY
 WHEN ddr_webservices_constants.g_roid_cd THEN
   x_fact_cols:='sum(x.ORDR_QTY) ORDR_QTY,'
   ||'sum(x.ORDR_AMT) ORDR_AMT';
   -- for RETAILER SHIP ITEM DAY
 WHEN ddr_webservices_constants.g_rsid_cd THEN
   x_fact_cols:= 'sum(x.SHIP_QTY) SHIP_QTY,'
   ||'sum(x.SHIP_AMT) SHIP_AMT';
                 -- for SALE FORECAST ITEM BY DAY
 WHEN ddr_webservices_constants.g_sfid_cd  THEN
   x_fact_cols:= 'sum(x.FRCST_SLS_QTY) FRCST_SLS_QTY,'
   ||'sum(x.FRCST_SLS_AMT) FRCST_SLS_AMT';
 END CASE;
 EXCEPTION
   WHEN OTHERS THEN
        x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
        x_msg_count:=1;
        x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
 END get_aggr_fact_colms;

 PROCEDURE get_detail_fact_colms(p_fact_code     IN  VARCHAR2,
                                 x_return_status OUT NOCOPY  VARCHAR2,
                                 x_msg_count     OUT NOCOPY  NUMBER,
                                 x_msg_data      OUT NOCOPY  VARCHAR2,
                                 x_fact_cols     OUT NOCOPY VARCHAR2)
 IS
 BEGIN
 --case condition to identify aggregate column names from fact table
 CASE p_fact_code
 -- for MARKET ITEM SALES DAY
 WHEN ddr_webservices_constants.g_misd_cd THEN
   x_fact_cols:='x.MFG_ORG_CD MFG_ORG_CD,'
   ||'x.RTL_ORG_CD RTL_ORG_CD,'
   ||'x.GLBL_ITEM_ID GLBL_ITEM_ID,'
   ||'x.MKT_AREA_ID MKT_AREA_ID,'
   ||'x.MKT_AREA_CD MKT_AREA_CD,'
   ||'x.DAY_CD DAY_CD,'

   ||'x.GLBL_ITEM_ID_TYP GLBL_ITEM_ID_TYP,'
   ||'x.MKT_ITEM_ID MKT_ITEM_ID,'
   ||'x.UOM_CD UOM_CD,'
   ||'x.UOM_CD_PRMRY UOM_CD_PRMRY,'
   ||'x.UOM_CD_ALT UOM_CD_ALT,'
   ||'x.CRNCY_CD CRNCY_CD,'
   ||'x.REC_CURR_DT REC_CURR_DT,'
   ||'x.AVG_MMACV_SLS_RATE AVG_MMACV_SLS_RATE,'
   ||'x.AVG_STORE_SELL_ITEM_QTY AVG_STORE_SELL_ITEM_QTY,'
   ||'x.AVG_STORE_SELL_ITEM_QTY_PRMRY AVG_STORE_SELL_ITEM_QTY_PRMRY,'
   ||'x.AVG_STORE_SELL_ITEM_QTY_ALT AVG_STORE_SELL_ITEM_QTY_ALT,'
   ||'x.AVG_ACV_WGT_DSTRBTN_PCT AVG_ACV_WGT_DSTRBTN_PCT,'
   ||'x.AVG_WGT_PRICE_RDCTN_PCT AVG_WGT_PRICE_RDCTN_PCT,'
   ||'x.SLS_QTY SLS_QTY,'
   ||'x.SLS_QTY_PRMRY SLS_QTY_PRMRY,'
   ||'x.SLS_QTY_ALT SLS_QTY_ALT,'
   ||'x.SLS_AMT SLS_AMT,'
   ||'x.SLS_AMT_LCL SLS_AMT_LCL,'
   ||'x.SLS_AMT_RPT SLS_AMT_RPT,'
   ||'x.NRML_QTY NRML_QTY,'
   ||'x.NRML_QTY_PRMRY NRML_QTY_PRMRY,'
   ||'x.NRML_QTY_ALT NRML_QTY_ALT,'
   ||'x.NRML_AMT NRML_AMT,'
   ||'x.NRML_AMT_LCL NRML_AMT_LCL,'
   ||'x.NRML_AMT_RPT NRML_AMT_RPT,'
   ||'x.SLS_PRICE_CUT_QTY SLS_PRICE_CUT_QTY,'
   ||'x.SLS_PRICE_CUT_QTY_PRMRY SLS_PRICE_CUT_QTY_PRMRY,'
   ||'x.SLS_PRICE_CUT_QTY_ALT SLS_PRICE_CUT_QTY_ALT,'
   ||'x.SLS_PRICE_CUT_AMT SLS_PRICE_CUT_AMT,'
   ||'x.SLS_PRICE_CUT_AMT_LCL SLS_PRICE_CUT_AMT_LCL,'
   ||'x.SLS_PRICE_CUT_AMT_RPT SLS_PRICE_CUT_AMT_RPT,'
   ||'x.MAIN_AD_QTY MAIN_AD_QTY,'
   ||'x.MAIN_AD_QTY_PRMRY MAIN_AD_QTY_PRMRY,'
   ||'x.MAIN_AD_QTY_ALT MAIN_AD_QTY_ALT,'
   ||'x.MAIN_AD_AMT MAIN_AD_AMT,'
   ||'x.MAIN_AD_AMT_LCL MAIN_AD_AMT_LCL,'
   ||'x.MAIN_AD_AMT_RPT MAIN_AD_AMT_RPT';
             --for PROMOTION PLAN
             --as there is a date range for promotion records, they would get selected for every day
             --therefore DISTINCT clause is added to ensure query doesn't return duplicates
 WHEN ddr_webservices_constants.g_pp_cd THEN
   x_fact_cols:='DISTINCT x.MFG_ORG_CD MFG_ORG_CD,'
   ||'x.RTL_ORG_CD RTL_ORG_CD,'
   ||'x.ORG_BSNS_UNIT_ID ORG_BSNS_UNIT_ID,'

   ||'x.PRMTN_TYP PRMTN_TYP,'
   ||'x.PRMTN_FROM_DT PRMTN_FROM_DT,'
   ||'x.PRMTN_TO_DT PRMTN_TO_DT,'
   ||'x.GLBL_ITEM_ID GLBL_ITEM_ID,'
   ||'x.RTL_SKU_ITEM_ID RTL_SKU_ITEM_ID,'
   ||'x.RTL_SKU_ITEM_NBR RTL_SKU_ITEM_NBR,'
   ||'x.GLBL_ITEM_ID_TYP GLBL_ITEM_ID_TYP,'
   ||'x.CRNCY_CD CRNCY_CD,'
   ||'x.PRMTN_PRICE_AMT PRMTN_PRICE_AMT,'
   ||'x.PRMTN_PRICE_AMT_LCL PRMTN_PRICE_AMT_LCL,'
   ||'x.PRMTN_PRICE_AMT_RPT PRMTN_PRICE_AMT_RPT';
 -- for RETAIL INVENTORY ITEM DAY
 WHEN ddr_webservices_constants.g_riid_cd THEN
   x_fact_cols:= 'x.MFG_ORG_CD MFG_ORG_CD,'
   ||'x.RTL_ORG_CD RTL_ORG_CD,'
   ||'x.ORG_BSNS_UNIT_ID ORG_BSNS_UNIT_ID,'

   ||'x.GLBL_ITEM_ID GLBL_ITEM_ID,'
   ||'x.RTL_SKU_ITEM_ID RTL_SKU_ITEM_ID,'
   ||'x.RTL_SKU_ITEM_NBR RTL_SKU_ITEM_NBR,'
   ||'x.DAY_CD DAY_CD,'
   ||'x.GLBL_ITEM_ID_TYP GLBL_ITEM_ID_TYP,'
   ||'x.INV_LOC_TYP_CD INV_LOC_TYP_CD,'
   ||'x.INV_LOC_ID INV_LOC_ID,'
   ||'x.INV_LOC_CD INV_LOC_CD,'
   ||'x.UOM_CD UOM_CD,'
   ||'x.UOM_CD_PRMRY UOM_CD_PRMRY,'
   ||'x.UOM_CD_ALT UOM_CD_ALT,'
   ||'x.CRNCY_CD CRNCY_CD,'
   ||'x.ON_HAND_QTY ON_HAND_QTY,'
   ||'x.ON_HAND_QTY_PRMRY ON_HAND_QTY_PRMRY,'
   ||'x.ON_HAND_QTY_ALT ON_HAND_QTY_ALT,'
   ||'x.RECVD_QTY RECVD_QTY,'
   ||'x.RECVD_QTY_PRMRY RECVD_QTY_PRMRY,'
   ||'x.RECVD_QTY_ALT RECVD_QTY_ALT,'
   ||'x.IN_TRANSIT_QTY IN_TRANSIT_QTY,'
   ||'x.IN_TRANSIT_QTY_PRMRY IN_TRANSIT_QTY_PRMRY,'
   ||'x.IN_TRANSIT_QTY_ALT IN_TRANSIT_QTY_ALT,'
   ||'x.BCK_ORDR_QTY BCK_ORDR_QTY,'
   ||'x.BCK_ORDR_QTY_PRMRY BCK_ORDR_QTY_PRMRY,'
   ||'x.BCK_ORDR_QTY_ALT BCK_ORDR_QTY_ALT,'
   ||'x.QLTY_HOLD_QTY QLTY_HOLD_QTY,'
   ||'x.QLTY_HOLD_QTY_PRMRY QLTY_HOLD_QTY_PRMRY,'
   ||'x.QLTY_HOLD_QTY_ALT QLTY_HOLD_QTY_ALT,'
   ||'x.ON_HAND_NET_COST_AMT ON_HAND_NET_COST_AMT,'
   ||'x.ON_HAND_NET_COST_AMT_LCL ON_HAND_NET_COST_AMT_LCL,'
   ||'x.ON_HAND_NET_COST_AMT_RPT ON_HAND_NET_COST_AMT_RPT,'
   ||'x.RECVD_NET_COST_AMT RECVD_NET_COST_AMT,'
   ||'x.RECVD_NET_COST_AMT_LCL RECVD_NET_COST_AMT_LCL,'
   ||'x.RECVD_NET_COST_AMT_RPT RECVD_NET_COST_AMT_RPT,'
   ||'x.IN_TRANSIT_NET_COST_AMT IN_TRANSIT_NET_COST_AMT,'
   ||'x.IN_TRANSIT_NET_COST_AMT_LCL IN_TRANSIT_NET_COST_AMT_LCL,'
   ||'x.IN_TRANSIT_NET_COST_AMT_RPT IN_TRANSIT_NET_COST_AMT_RPT,'
   ||'x.BCKORDR_NET_COST_AMT BCKORDR_NET_COST_AMT,'
   ||'x.BCKORDR_NET_COST_AMT_LCL BCKORDR_NET_COST_AMT_LCL,'
   ||'x.BCKORDR_NET_COST_AMT_RPT BCKORDR_NET_COST_AMT_RPT,'
   ||'x.QLTY_HOLD_NET_COST_AMT QLTY_HOLD_NET_COST_AMT,'
   ||'x.QLTY_HOLD_NET_COST_AMT_LCL QLTY_HOLD_NET_COST_AMT_LCL,'
   ||'x.QLTY_HOLD_NET_COST_AMT_RPT QLTY_HOLD_NET_COST_AMT_RPT,'
   ||'x.ON_HAND_RTL_AMT ON_HAND_RTL_AMT,'
   ||'x.ON_HAND_RTL_AMT_LCL ON_HAND_RTL_AMT_LCL,'
   ||'x.ON_HAND_RTL_AMT_RPT ON_HAND_RTL_AMT_RPT,'
   ||'x.RECVD_RTL_AMT RECVD_RTL_AMT,'
   ||'x.RECVD_RTL_AMT_LCL RECVD_RTL_AMT_LCL,'
   ||'x.RECVD_RTL_AMT_RPT RECVD_RTL_AMT_RPT,'
   ||'x.IN_TRANSIT_RTL_AMT IN_TRANSIT_RTL_AMT,'
   ||'x.IN_TRANSIT_RTL_AMT_LCL IN_TRANSIT_RTL_AMT_LCL,'
   ||'x.IN_TRANSIT_RTL_AMT_RPT IN_TRANSIT_RTL_AMT_RPT,'
   ||'x.BCKORDR_RTL_AMT BCKORDR_RTL_AMT,'
   ||'x.BCKORDR_RTL_AMT_LCL BCKORDR_RTL_AMT_LCL,'
   ||'x.BCKORDR_RTL_AMT_RPT BCKORDR_RTL_AMT_RPT,'
   ||'x.QLTY_HOLD_RTL_AMT QLTY_HOLD_RTL_AMT,'
   ||'x.QLTY_HOLD_RTL_AMT_LCL QLTY_HOLD_RTL_AMT_LCL,'
   ||'x.QLTY_HOLD_RTL_AMT_RPT QLTY_HOLD_RTL_AMT_RPT';
 -- for RETAIL SALE RETURN ITEM DAY fact
 WHEN ddr_webservices_constants.g_rsrid_cd THEN
   x_fact_cols:='x.MFG_ORG_CD MFG_ORG_CD,'
   ||'x.RTL_ORG_CD RTL_ORG_CD,'
   ||'x.ORG_BSNS_UNIT_ID ORG_BSNS_UNIT_ID,'

   ||'x.DAY_CD DAY_CD,'
   ||'x.GLBL_ITEM_ID GLBL_ITEM_ID,'
   ||'x.RTL_SKU_ITEM_ID RTL_SKU_ITEM_ID,'
   ||'x.RTL_SKU_ITEM_NBR RTL_SKU_ITEM_NBR,'
   ||'x.GLBL_ITEM_ID_TYP GLBL_ITEM_ID_TYP,'
   ||'x.UOM_CD UOM_CD,'
   ||'x.UOM_CD_PRMRY UOM_CD_PRMRY,'
   ||'x.UOM_CD_ALT UOM_CD_ALT,'
   ||'x.CRNCY_CD CRNCY_CD,'
   ||'x.SLS_QTY SLS_QTY,'
   ||'x.SLS_QTY_PRMRY SLS_QTY_PRMRY,'
   ||'x.SLS_QTY_ALT SLS_QTY_ALT,'
   ||'x.SLS_AMT SLS_AMT,'
   ||'x.SLS_AMT_LCL SLS_AMT_LCL,'
   ||'x.SLS_AMT_RPT SLS_AMT_RPT,'
   ||'x.SLS_COST_AMT SLS_COST_AMT,'
   ||'x.SLS_COST_AMT_LCL SLS_COST_AMT_LCL,'
   ||'x.SLS_COST_AMT_RPT SLS_COST_AMT_RPT,'
   ||'x.RTRN_QTY RTRN_QTY,'
   ||'x.RTRN_QTY_PRMRY RTRN_QTY_PRMRY,'
   ||'x.RTRN_QTY_ALT RTRN_QTY_ALT,'
   ||'x.RTRN_AMT RTRN_AMT,'
   ||'x.RTRN_AMT_LCL RTRN_AMT_LCL,'
   ||'x.RTRN_AMT_RPT RTRN_AMT_RPT,'
   ||'x.RTRN_COST_AMT RTRN_COST_AMT,'
   ||'x.RTRN_COST_AMT_LCL RTRN_COST_AMT_LCL,'
   ||'x.RTRN_COST_AMT_RPT RTRN_COST_AMT_RPT';
  -- for RETAILER ORDER ITEM DAY
 WHEN ddr_webservices_constants.g_roid_cd THEN
   x_fact_cols:='x.MFG_ORG_CD MFG_ORG_CD,'
   ||'x.RTL_ORG_CD RTL_ORG_CD,'
   ||'x.ORG_BSNS_UNIT_ID ORG_BSNS_UNIT_ID,'

   ||'x.DAY_CD DAY_CD,'
   ||'x.GLBL_ITEM_ID GLBL_ITEM_ID,'
   ||'x.RTL_SKU_ITEM_ID RTL_SKU_ITEM_ID,'
   ||'x.RTL_SKU_ITEM_NBR RTL_SKU_ITEM_NBR,'
   ||'x.GLBL_ITEM_ID_TYP GLBL_ITEM_ID_TYP,'
   ||'x.UOM_CD UOM_CD,'
   ||'x.UOM_CD_PRMRY UOM_CD_PRMRY,'
   ||'x.UOM_CD_ALT UOM_CD_ALT,'
   ||'x.CRNCY_CD CRNCY_CD,'
   ||'x.ORDR_QTY ORDR_QTY,'
   ||'x.ORDR_QTY_PRMRY ORDR_QTY_PRMRY,'
   ||'x.ORDR_QTY_ALT ORDR_QTY_ALT,'
   ||'x.ORDR_AMT ORDR_AMT,'
   ||'x.ORDR_AMT_LCL ORDR_AMT_LCL,'
   ||'x.ORDR_AMT_RPT ORDR_AMT_RPT';
  -- for RETAILER SHIP ITEM DAY
  WHEN ddr_webservices_constants.g_rsid_cd THEN
   x_fact_cols:= 'x.MFG_ORG_CD MFG_ORG_CD,'
   ||'x.RTL_ORG_CD RTL_ORG_CD,'
   ||'x.ORG_BSNS_UNIT_ID ORG_BSNS_UNIT_ID,'

   ||'x.DAY_CD DAY_CD,'
   ||'x.GLBL_ITEM_ID GLBL_ITEM_ID,'
   ||'x.RTL_SKU_ITEM_ID RTL_SKU_ITEM_ID,'
   ||'x.RTL_SKU_ITEM_NBR RTL_SKU_ITEM_NBR,'
   ||'x.GLBL_ITEM_ID_TYP GLBL_ITEM_ID_TYP,'
   ||'x.UOM_CD UOM_CD,'
   ||'x.UOM_CD_PRMRY UOM_CD_PRMRY,'
   ||'x.UOM_CD_ALT UOM_CD_ALT,'
   ||'x.CRNCY_CD CRNCY_CD,'
   ||'x.SHIP_QTY SHIP_QTY,'
   ||'x.SHIP_QTY_PRMRY SHIP_QTY_PRMRY,'
   ||'x.SHIP_QTY_ALT SHIP_QTY_ALT,'
   ||'x.SHIP_AMT SHIP_AMT,'
   ||'x.SHIP_AMT_LCL SHIP_AMT_LCL,'
   ||'x.SHIP_AMT_RPT SHIP_AMT_RPT';
  -- for SALE FORECAST ITEM BY DAY
 WHEN ddr_webservices_constants.g_sfid_cd  THEN
   x_fact_cols:= 'x.MFG_ORG_CD MFG_ORG_CD,'
   ||'x.RTL_ORG_CD RTL_ORG_CD,'
   ||'x.FRCST_NBR FRCST_NBR,'
   ||'x.FRCST_TYP FRCST_TYP,'
   ||'x.FRCST_VRSN FRCST_VRSN,'
   ||'x.ORG_BSNS_UNIT_ID ORG_BSNS_UNIT_ID,'

   ||'x.DAY_CD DAY_CD,'
   ||'x.GLBL_ITEM_ID GLBL_ITEM_ID,'
   ||'x.RTL_SKU_ITEM_ID RTL_SKU_ITEM_ID,'
   ||'x.RTL_SKU_ITEM_NBR RTL_SKU_ITEM_NBR,'
   ||'x.GLBL_ITEM_ID_TYP GLBL_ITEM_ID_TYP,'
   ||'x.FRCST_SLS_UOM_CD FRCST_SLS_UOM_CD,'
   ||'x.FRCST_SLS_UOM_CD_PRMRY FRCST_SLS_UOM_CD_PRMRY,'
   ||'x.FRCST_SLS_UOM_CD_ALT FRCST_SLS_UOM_CD_ALT,'
   ||'x.CRNCY_CD CRNCY_CD,'
   ||'x.FRCST_SLS_QTY FRCST_SLS_QTY,'
   ||'x.FRCST_SLS_QTY_PRMRY FRCST_SLS_QTY_PRMRY,'
   ||'x.FRCST_SLS_QTY_ALT FRCST_SLS_QTY_ALT,'
   ||'x.FRCST_SLS_AMT FRCST_SLS_AMT,'
   ||'x.FRCST_SLS_AMT_LCL FRCST_SLS_AMT_LCL,'
   ||'x.FRCST_SLS_AMT_RPT FRCST_SLS_AMT_RPT';
 END CASE;
 x_return_status:=ddr_webservices_constants.g_ret_sts_success;
 EXCEPTION
  WHEN OTHERS THEN
        x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
        x_msg_count:=1;
        x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
 END get_detail_fact_colms;

 PROCEDURE get_aggr_group_colms(p_exp_org_level  IN  VARCHAR2,
                                p_exp_loc_level  IN  VARCHAR2,
                                p_exp_item_level IN  VARCHAR2,
                                p_exp_time_level IN  VARCHAR2,
                                x_return_status  OUT NOCOPY  VARCHAR2,
                                x_msg_count      OUT NOCOPY  NUMBER,
                                x_msg_data       OUT NOCOPY  VARCHAR2,
                                x_group_col      OUT NOCOPY VARCHAR2)
 IS
    l_group_col      VARCHAR2(500):=null;
    l_ref_join       VARCHAR2(100):=null;
    l_lvl_rnk        NUMBER:=null;
    l_hrchy_lvl_name VARCHAR2(50):=null;
 BEGIN
    --get aggregate columns for the Organization hierarchy based on given hierarchy level code
    IF p_exp_org_level IS NOT NULL THEN
     get_hrchy_lvl('ORGANIZATION',p_exp_org_level,l_lvl_rnk,x_return_status,x_msg_count,x_msg_data);
     IF x_return_status<>ddr_webservices_constants.g_ret_sts_success THEN
       RETURN;
     END IF;
     get_org_ref_join(l_lvl_rnk,l_group_col,x_return_status, x_msg_count,x_msg_data);
    END IF;
    --get aggregate columns for the location hierarchy based on given hierarchy level code
    IF p_exp_loc_level IS NOT NULL  THEN
       get_hrchy_lvl('LOCATION',p_exp_loc_level,l_lvl_rnk,x_return_status,x_msg_count,x_msg_data);
       IF x_return_status<>ddr_webservices_constants.g_ret_sts_success THEN
         RETURN;
       END IF;
       get_loc_ref_join(l_lvl_rnk,l_ref_join,x_return_status, x_msg_count,x_msg_data);
       IF l_group_col IS NOT NUll THEN
          l_group_col :=l_group_col ||','||l_ref_join;
       ELSIF l_group_col IS NUll THEN
          l_group_col :=l_ref_join;
       END IF;
    END IF;
    --get aggregate columns for the Item hierarchy based on given hierarchy level code
    IF p_exp_item_level IS NOT NULL  THEN
       get_hrchy_lvl('ITEM',p_exp_item_level,l_lvl_rnk,x_return_status,x_msg_count,x_msg_data);
     IF x_return_status<>ddr_webservices_constants.g_ret_sts_success THEN
       RETURN;
     END IF;
     get_item_ref_join(l_lvl_rnk,l_ref_join,x_return_status, x_msg_count,x_msg_data);
     IF l_group_col IS NOT NUll THEN
      l_group_col :=l_group_col ||','||l_ref_join;
     ELSIF l_group_col IS NUll THEN
      l_group_col :=l_ref_join;
     END IF;
    END IF;
    --get aggregate columns for the time hierarchy based on given hierarchy level code
    IF p_exp_time_level IS NOT NULL  THEN
       SELECT hrchy_lvl_name INTO l_hrchy_lvl_name FROM DDR_WS_METADATA WHERE hrchy_lvl_cd=p_exp_time_level;
       get_hrchy_lvl(l_hrchy_lvl_name,p_exp_time_level,l_lvl_rnk,x_return_status,x_msg_count,x_msg_data);
     IF x_return_status<>ddr_webservices_constants.g_ret_sts_success THEN
       RETURN;
     END IF;
     get_time_ref_join(l_hrchy_lvl_name,l_lvl_rnk,l_ref_join,x_return_status, x_msg_count,x_msg_data);
     IF l_group_col IS NOT NUll THEN
       l_group_col :=l_group_col ||','||l_ref_join;
     ELSIF l_group_col IS NUll THEN
       l_group_col :=l_ref_join;
     END IF;
    END IF;
 x_group_col:= l_group_col;
 x_return_status:=ddr_webservices_constants.g_ret_sts_success;
 EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
        x_msg_count:=1;
        x_msg_data:='No Data Found. Error code:'||sqlcode||' Error message:'||sqlerrm;
      WHEN OTHERS THEN
        x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
        x_msg_count:=1;
        x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
 END get_aggr_group_colms;

 PROCEDURE write_fact_to_xml_file(p_query         IN VARCHAR2,
                                  p_fact_code     IN VARCHAR2,
                                  p_job_id        IN  NUMBER,
                                  x_return_status OUT NOCOPY  VARCHAR2,
                                  x_msg_count     OUT NOCOPY  NUMBER,
                                  x_msg_data      OUT NOCOPY  VARCHAR2)
 IS
  l_cur             NUMBER:=null;
  l_dtbl            DBMS_SQL.desc_tab;
  l_cnt             NUMBER;
  l_status          NUMBER;
  l_val             VARCHAR2(200);
  l_col_name        VARCHAR2(200);
  l_xml_file        UTL_FILE.file_type;
  l_fetch_ctn       NUMBER:=0;
  l_fetch_rows      NUMBER:=0;
  l_file_name       VARCHAR2(30):=null;
  l_total_row_count NUMBER:=0;
  l_dir_name        VARCHAR2(30):=null;
  l_pagination_row_count NUMBER:=null;
  l_max_row_count   NUMBER:=null;
  l_fact            VARCHAR2(32767):=null;
  l_file_id         VARCHAR2(100):= NULL;
  l_max_rows EXCEPTION;
 BEGIN
   --get logical directory name from system variable table
   ddr_webservices_pub.get_sys_var_val('OUTPUT_DIR_PATH',x_return_status, x_msg_count,x_msg_data,l_dir_name);
   --get pagination row count from system variable table
   ddr_webservices_pub.get_sys_var_val('MAX_REC_PER_FILE',x_return_status, x_msg_count,x_msg_data,l_pagination_row_count);
   --get threashold value for the maximum records for which files can be created
   ddr_webservices_pub.get_sys_var_val('MAX_OUT NOCOPY PUT_RECORDS',x_return_status, x_msg_count,x_msg_data,l_max_row_count);
   -- DBMS_OUTPUT.PUT_LINE('l_max_row_count='||l_max_row_count);
   l_pagination_row_count:=to_number(l_pagination_row_count);
   --get file id
   l_file_id :=get_ddr_ws_file_seq_nextval(x_return_status,x_msg_count,x_msg_data);
   --construct file name
   l_file_name :=  p_fact_code || '_'|| l_file_id || '.xml';
   --open file in write mode
   l_xml_file := UTL_FILE.fopen(l_dir_name,l_file_name,ddr_webservices_constants.g_file_write_mode);
   --write xml header data in the xml file
   UTL_FILE.put_line(l_xml_file, '<?xml version="1.0" encoding="UTF-8"?>');
   --open cursor
   l_cur := dbms_sql.open_cursor;
   dbms_sql.parse(l_cur,p_query,dbms_sql.native);
   l_status := dbms_sql.execute(l_cur);
   --to column defination from the cursor
   dbms_sql.describe_columns(l_cur,l_cnt,l_dtbl);
   FOR i in 1..l_cnt LOOP
      dbms_sql.define_column(l_cur,i,l_val,30);
   END LOOP;
   UTL_FILE.put_line(l_xml_file, '<FACT_DATA>');
   l_fetch_rows:=dbms_sql.fetch_rows(l_cur);
   WHILE ( l_fetch_rows > 0 ) LOOP
     l_fetch_ctn:=l_fetch_ctn+l_fetch_rows;
     UTL_FILE.put_line(l_xml_file, '<FACT>');
     l_fact:=null;
     --write individual row in the xml file
   FOR i in 1..l_cnt loop
     l_col_name:= l_dtbl(i).col_name;
     dbms_sql.column_value(l_cur,i,l_val);
     -- l_fact:=l_fact||'<'||l_col_name||'>'||l_val||'</'||l_col_name||'>'||chr(10);
     -- Use of chr function not allowed by GSCC. The new line character is introduced using line edit
     l_fact:=l_fact||'<'||l_col_name||'>'||l_val||'</'||l_col_name||'>'||'
'||NULL;
   END LOOP;
   -- UTL_FILE.put_line(l_xml_file, l_fact||chr(10)||'</FACT>');
   -- Use of chr function not allowed by GSCC. The new line character is introduced using line edit
   UTL_FILE.put_line(l_xml_file, l_fact||'
'||'</FACT>');
   IF l_fetch_ctn = l_pagination_row_count THEN
    UTL_FILE.put_line(l_xml_file,'</FACT_DATA>');
    UTL_FILE.FCLOSE(l_xml_file);
    --update the job file metadata table with the file name
    BEGIN
         INSERT INTO ddr_ws_job_file_dls(file_id, job_id, file_name, status, delete_flag,src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr,
                created_by, creation_date, last_updated_by,
                last_update_date, last_update_login)
         VALUES (l_file_id, p_job_id, l_file_name, ddr_webservices_constants.g_ret_sts_success, 'N','ABC', SYSDATE, 'ABC', 'ABC',101, SYSDATE, 101,
                SYSDATE, 101);
    END;
    l_fetch_rows:=dbms_sql.fetch_rows(l_cur);
    IF(l_fetch_rows > 0) THEN
      IF l_total_row_count >=l_max_row_count THEN
        RAISE l_max_rows;
      END IF;
      l_file_id :=get_ddr_ws_file_seq_nextval(x_return_status,x_msg_count,x_msg_data);
      l_file_name :=  p_fact_code || '_'|| l_file_id || '.xml';
      l_xml_file := UTL_FILE.fopen(l_dir_name,l_file_name,ddr_webservices_constants.g_file_write_mode);
      UTL_FILE.put_line(l_xml_file, '<?xml version="1.0" encoding="UTF-8"?>');
      UTL_FILE.put_line(l_xml_file, '<FACT_DATA>');
      l_fetch_ctn:=0;
    END IF;
   ELSE
    l_fetch_rows:=dbms_sql.fetch_rows(l_cur);
   END IF;
   l_total_row_count:=l_total_row_count+1;
   END LOOP;
   -- DBMS_OUTPUT.PUT_LINE('l_total_row_count='||l_total_row_count);
   dbms_sql.close_cursor(l_cur);
   IF l_fetch_ctn <> l_pagination_row_count THEN
       UTL_FILE.put_line(l_xml_file, '</FACT_DATA>');
       UTL_FILE.FCLOSE(l_xml_file);
   BEGIN
       -- DBMS_OUTPUT.PUT_LINE('third, l_file_id='||l_file_id);
       INSERT INTO ddr_ws_job_file_dls
               (file_id, job_id, file_name, status, delete_flag,
                src_sys_idnt, src_sys_dt, crtd_by_dsr, last_updt_by_dsr,
                created_by, creation_date, last_updated_by,
                last_update_date, last_update_login
               )
        VALUES (l_file_id, p_job_id, l_file_name, ddr_webservices_constants.g_ret_sts_success, 'N',
                'ABC', SYSDATE, 'ABC', 'ABC',101, SYSDATE, 101,
                SYSDATE, 101);
   END;
   END IF;
   x_return_status:=ddr_webservices_constants.g_ret_sts_success;
 EXCEPTION
   WHEN l_max_rows THEN
      IF dbms_sql.is_open(l_cur) THEN
        dbms_sql.close_cursor(l_cur);
      END IF;
      IF UTL_FILE.is_open(l_xml_file) THEN
        UTL_FILE.fclose(l_xml_file);
      END IF;
      x_return_status:=ddr_webservices_constants.g_ret_sts_error;
      x_msg_count:=1;
      x_msg_data:='Program exceeded maximum row OUT NOCOPY put';
   WHEN UTL_FILE.INTERNAL_ERROR THEN
      IF dbms_sql.is_open(l_cur) THEN
        dbms_sql.close_cursor(l_cur);
      END IF;
      IF UTL_FILE.is_open(l_xml_file) THEN
        UTL_FILE.fclose(l_xml_file);
      END IF;
      x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
      x_msg_count:=1;
      x_msg_data:='Cannot open file :' || l_file_name ||', write error; code:' || sqlcode ||',message:' || sqlerrm;
   WHEN UTL_FILE.INVALID_OPERATION THEN
      IF dbms_sql.is_open(l_cur) THEN
        dbms_sql.close_cursor(l_cur);
      END IF;
      IF UTL_FILE.is_open(l_xml_file) THEN
        UTL_FILE.fclose(l_xml_file);
      END IF;
      x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
      x_msg_count:=1;
      x_msg_data:='Cannot open file :' || l_file_name ||', write error; code:' || sqlcode ||',message:' || sqlerrm;
   WHEN UTL_FILE.INVALID_PATH THEN
      IF dbms_sql.is_open(l_cur) THEN
        dbms_sql.close_cursor(l_cur);
      END IF;
      IF UTL_FILE.is_open(l_xml_file) THEN
         UTL_FILE.fclose(l_xml_file);
      END IF;
      x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
      x_msg_count:=1;
      x_msg_data:='Cannot open file :' || l_file_name ||', write error; code:' || sqlcode ||',message:' || sqlerrm;
    WHEN UTL_FILE.WRITE_ERROR THEN
      IF dbms_sql.is_open(l_cur) THEN
        dbms_sql.close_cursor(l_cur);
      END IF;
      IF UTL_FILE.is_open(l_xml_file) THEN
        UTL_FILE.fclose(l_xml_file);
      END IF;
      x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
      x_msg_count:=1;
      x_msg_data:='Cannot write to file :' || l_file_name ||', write error; code:' || sqlcode ||',message:' || sqlerrm;
    WHEN OTHERS THEN
      IF dbms_sql.is_open(l_cur) THEN
        dbms_sql.close_cursor(l_cur);
      END IF;
      IF UTL_FILE.is_open(l_xml_file) THEN
         UTL_FILE.fclose(l_xml_file);
      END IF;
      x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
      x_msg_count:=1;
      x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
 END write_fact_to_xml_file;

 PROCEDURE validate_input_params(p_api_version     IN  NUMBER,
                                 p_mfg_org_cd      IN  VARCHAR2,
                                 p_org_cd          IN  VARCHAR2,
                                 p_org_dim_lvl_cd  IN  VARCHAR2,
                                 p_org_lvl_val     IN  VARCHAR2,
                                 p_exp_org_level   IN  VARCHAR2,
                                 p_loc_dim_lvl_cd  IN  VARCHAR2,
                                 p_loc_lvl_val     IN  VARCHAR2,
                                 p_exp_loc_level   IN  VARCHAR2,
                                 p_item_dim_lvl_cd IN  VARCHAR2,
                                 p_item_lvl_val    IN  VARCHAR2,
                                 p_exp_item_level  IN  VARCHAR2,
                                 p_time_dim_lvl_cd IN  VARCHAR2,
                                 p_time_lvl_val    IN  VARCHAR2,
                                 p_exp_time_level  IN  VARCHAR2,
                                 p_fact_code       IN  VARCHAR2,
                                 x_return_status   OUT NOCOPY  VARCHAR2,
                                 x_msg_count       OUT NOCOPY  NUMBER,
                                 x_msg_data        OUT NOCOPY  VARCHAR2)
 IS
  l_api_ver           EXCEPTION;
  l_fact_code_null    EXCEPTION;
  l_mfg_code_null     EXCEPTION;
  l_rtl_org_code_null EXCEPTION;
  l_pp_invld_aggr     EXCEPTION;
  l_hrchy_cd          VARCHAR2(50):=NULL;
 BEGIN
   IF p_api_version IS NULL THEN
     RAISE l_api_ver;
   END IF;
   IF p_api_version<>ddr_webservices_constants.g_api_version THEN
     RAISE l_api_ver;
   END IF;
   IF p_fact_code IS NULL THEN
     RAISE l_fact_code_null;
   END IF;
   IF p_mfg_org_cd IS NULL THEN
     RAISE l_mfg_code_null;
   END IF;
   IF p_org_cd IS NULL THEN
     RAISE l_rtl_org_code_null;
   END IF;
   IF p_fact_code = ddr_webservices_constants.g_pp_cd AND p_exp_time_level IS NOT NULL  THEN
     RAISE l_pp_invld_aggr;
   END IF;
   x_return_status:=ddr_webservices_constants.g_ret_sts_success;
 EXCEPTION
   WHEN l_api_ver THEN
      x_return_status:=ddr_webservices_constants.g_ret_sts_error;
      x_msg_count:=1;
      x_msg_data:='API version number should not be null';
   WHEN l_fact_code_null THEN
      x_return_status:=ddr_webservices_constants.g_ret_sts_error;
      x_msg_count:=1;
      x_msg_data:='Fact code should not be null';
   WHEN l_mfg_code_null THEN
      x_return_status:=ddr_webservices_constants.g_ret_sts_error;
      x_msg_count:=1;
      x_msg_data:='Manufacturer Organization code should not be null';
   WHEN l_rtl_org_code_null THEN
      x_return_status:=ddr_webservices_constants.g_ret_sts_error;
      x_msg_count:=1;
      x_msg_data:='Retailer Organization code should not be null';
   WHEN l_pp_invld_aggr THEN
      x_return_status:=ddr_webservices_constants.g_ret_sts_error;
      x_msg_count:=1;
      x_msg_data:='Time based aggregation is not supported for Promotion Plan data';
   WHEN OTHERS THEN
      x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
      x_msg_count:=1;
      x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
 END validate_input_params;

 PROCEDURE get_sys_var_val(p_sys_var       IN  VARCHAR2,
                           x_return_status OUT NOCOPY  VARCHAR2,
                           x_msg_count     OUT NOCOPY  NUMBER,
                           x_msg_data      OUT NOCOPY  VARCHAR2,
                           x_sys_var_val   OUT NOCOPY VARCHAR2)
 IS
 BEGIN
      SELECT lkup_name INTO x_sys_var_val FROM ddr_r_lkup_mst WHERE lkup_cd=p_sys_var;
      x_return_status:=ddr_webservices_constants.g_ret_sts_success;
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
        x_return_status := ddr_webservices_constants.g_ret_sts_error;
        x_msg_count := 1;
        x_msg_data := 'No Data Found. Error Code' ||sqlcode||' Error message:'||sqlerrm;
 WHEN OTHERS THEN
        x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
        x_msg_count:=1;
        x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
 END get_sys_var_val;

 FUNCTION get_ddr_ws_file_seq_nextval(x_return_status OUT NOCOPY  VARCHAR2,
                                      x_msg_count     OUT NOCOPY  NUMBER,
                                      x_msg_data      OUT NOCOPY  VARCHAR2) RETURN VARCHAR2
 IS
   l_next_val NUMBER:=null;
 BEGIN
    SELECT DDR_WS_FILE_SEQ.NEXTVAL INTO l_next_val FROM dual;
    RETURN to_char(l_next_val);
 EXCEPTION
 WHEN NO_DATA_FOUND THEN
    x_return_status := ddr_webservices_constants.g_ret_sts_error;
    x_msg_count := 1;
    x_msg_data := 'No Data Found. Error Code' ||sqlcode||' Error message:'||sqlerrm;
 WHEN OTHERS THEN
    x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
    x_msg_count:=1;
    x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
 END get_ddr_ws_file_seq_nextval;

 PROCEDURE get_itm_hrchy_clauses(p_item_dim_lvl_cd IN VARCHAR2,
                                 p_item_lvl_val    IN VARCHAR2,
                                 p_exp_item_level  IN VARCHAR2,
                                 p_fact_code       IN VARCHAR2,
                                 x_return_status   OUT NOCOPY  VARCHAR2,
                                 x_msg_count       OUT NOCOPY  VARCHAR2,
                                 x_msg_data        OUT NOCOPY  VARCHAR2,
                                 x_itm_ref_tbls    OUT NOCOPY  VARCHAR2,
                                 x_itm_ref_joins   OUT NOCOPY  VARCHAR2,
                                 x_itm_where_clus  OUT NOCOPY  VARCHAR2)
 IS
   l_lvl_rnk NUMBER:=null;
 BEGIN
 -- CASE p_fact_code
 -- for RETAIL SALE RETURN ITEM DAY fact
 --WHEN ddr_webservices_constants.g_rsrid_cd THEN

 IF p_item_dim_lvl_cd IS NOT NULL THEN
    get_hrchy_lvl('ITEM',p_item_dim_lvl_cd,l_lvl_rnk,x_return_status,x_msg_count,x_msg_data);
 ELSIF p_exp_item_level IS NOT NULL THEN
    get_hrchy_lvl('ITEM',p_exp_item_level,l_lvl_rnk,x_return_status,x_msg_count,x_msg_data);
 END IF;
 IF l_lvl_rnk IS NULL THEN
   RETURN;
 END IF;
 IF l_lvl_rnk>=1 THEN
   x_itm_ref_tbls:=',DDR_R_MFG_SKU_ITEM ITMA';
   x_itm_ref_joins:='AND x.GLBL_ITEM_ID = ITMA.GLBL_ITEM_ID';
 END IF;
 IF l_lvl_rnk>=2 THEN
   x_itm_ref_tbls:=x_itm_ref_tbls || ',DDR_R_MFG_ITEM ITMB';
   x_itm_ref_joins:=x_itm_ref_joins||' AND ITMA.MFG_ITEM_ID = ITMB.MFG_ITEM_ID';
 END IF;
 IF l_lvl_rnk>=3 THEN
   x_itm_ref_tbls:=x_itm_ref_tbls || ',DDR_R_MFG_ITEM_SBC ITMC';
   x_itm_ref_joins:=x_itm_ref_joins||' AND ITMB.MFG_ITEM_SBC_ID = ITMC.MFG_ITEM_SBC_ID';
 END IF;
 IF l_lvl_rnk>=4 THEN
   x_itm_ref_tbls:=x_itm_ref_tbls || ',DDR_R_MFG_ITEM_CLASS ITMD';
   x_itm_ref_joins:=x_itm_ref_joins||' AND ITMC.MFG_ITEM_CLASS_ID = ITMD.MFG_ITEM_CLASS_ID';
 END IF;
 IF l_lvl_rnk>=5 THEN
   x_itm_ref_tbls:=x_itm_ref_tbls || ',DDR_R_MFG_ITEM_GRP ITME';
   x_itm_ref_joins:=x_itm_ref_joins||' AND ITMD.MFG_ITEM_GRP_ID = ITME.MFG_ITEM_GRP_ID';
 END IF;
 IF l_lvl_rnk>=6 THEN
   x_itm_ref_tbls:=x_itm_ref_tbls || ',DDR_R_MFG_ITEM_DIV ITMF';
   x_itm_ref_joins:=x_itm_ref_joins||' AND ITME.MFG_ITEM_DIV_ID = ITMF.MFG_ITEM_DIV_ID';
 END IF;
 IF p_item_dim_lvl_cd IS NOT NULL THEN
    get_item_ref_join(l_lvl_rnk,x_itm_where_clus,x_return_status,x_msg_count,x_msg_data);
    x_itm_where_clus:= x_itm_where_clus || '=''' || p_item_lvl_val||'''';
 END IF;
 -- END CASE;
 EXCEPTION
 WHEN OTHERS THEN
        x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
        x_msg_count:=1;
        x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
 END get_itm_hrchy_clauses;

 PROCEDURE get_item_ref_join(p_lvl_rnk         IN NUMBER,
                             x_ref_join        OUT NOCOPY  VARCHAR2,
                             x_return_status   OUT NOCOPY  VARCHAR2,
                             x_msg_count       OUT NOCOPY  VARCHAR2,
                             x_msg_data        OUT NOCOPY  VARCHAR2)
 IS
 BEGIN
 CASE p_lvl_rnk
  WHEN 1 THEN
    x_ref_join:=' ITMA.MFG_SKU_ITEM_NBR';
  WHEN 2 THEN
    x_ref_join:=' ITMB.MFG_ITEM_NBR ';
  WHEN 3 THEN
    x_ref_join:=' ITMC.MFG_SBC_CD ';
  WHEN 4 THEN
    x_ref_join:=' ITMD.MFG_CLASS_CD ';
  WHEN 5 THEN
    x_ref_join:=' ITME.MFG_GRP_CD ';
  WHEN 6 THEN
    x_ref_join:=' ITMF.MFG_DIV_CD ';
 END CASE;
 EXCEPTION
 WHEN OTHERS THEN
      x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
      x_msg_count:=1;
      x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;

 END get_item_ref_join;


 PROCEDURE get_org_hrchy_clauses(p_org_dim_lvl_cd  IN  VARCHAR2,
                                 p_org_lvl_val     IN  VARCHAR2,
                                 p_exp_org_level   IN  VARCHAR2,
                                 p_fact_code       IN  VARCHAR2,
                                 x_return_status   OUT NOCOPY  VARCHAR2,
                                 x_msg_count       OUT NOCOPY  VARCHAR2,
                                 x_msg_data        OUT NOCOPY  VARCHAR2,
                                 x_org_ref_tbls    OUT NOCOPY  VARCHAR2,
                                 x_org_ref_joins   OUT NOCOPY  VARCHAR2,
                                 x_org_where_clus  OUT NOCOPY  VARCHAR2)
 IS
   l_lvl_rnk NUMBER:=null;
 BEGIN
  -- CASE p_fact_code
  -- for RETAIL SALE RETURN ITEM DAY fact
  --WHEN ddr_webservices_constants.g_rsrid_cd THEN
  IF p_org_dim_lvl_cd IS NOT NULL THEN
      get_hrchy_lvl('ORGANIZATION',p_org_dim_lvl_cd,l_lvl_rnk,x_return_status,x_msg_count,x_msg_data);
  ELSIF p_exp_org_level IS NOT NULL THEN
	get_hrchy_lvl('ORGANIZATION',p_exp_org_level,l_lvl_rnk,x_return_status,x_msg_count,x_msg_data);
  END IF;
  IF l_lvl_rnk IS NULL THEN
     RETURN;
  END IF;
  IF l_lvl_rnk>=1 THEN
     x_org_ref_tbls:=',DDR_R_ORG_BSNS_UNIT ORGA';
     x_org_ref_joins:=' AND X.ORG_BSNS_UNIT_ID = ORGA.ORG_BSNS_UNIT_ID';
  END IF;
  IF l_lvl_rnk>=2 THEN
     x_org_ref_tbls:=x_org_ref_tbls || ',DDR_R_ORG_DSTRCT ORGB';
     x_org_ref_joins:=x_org_ref_joins||' AND ORGA.ORG_DSTRCT_ID = ORGB.ORG_DSTRCT_ID';
  END IF;
  IF l_lvl_rnk>=3 THEN
     x_org_ref_tbls:=x_org_ref_tbls || ',DDR_R_ORG_RGN ORGC';
     x_org_ref_joins:=x_org_ref_joins||' AND ORGB.ORG_RGN_ID = ORGC.ORG_RGN_ID';
  END IF;
  IF l_lvl_rnk>=4 THEN
     x_org_ref_tbls:=x_org_ref_tbls || ',DDR_R_ORG_AREA ORGD';
     x_org_ref_joins:=x_org_ref_joins||' AND ORGC.ORG_AREA_ID = ORGD.ORG_AREA_ID';
  END IF;
  IF l_lvl_rnk>=5 THEN
     x_org_ref_tbls:=x_org_ref_tbls || ',DDR_R_ORG_CHAIN ORGE';
     x_org_ref_joins:=x_org_ref_joins||' AND ORGD.ORG_CHAIN_ID = ORGE.ORG_CHAIN_ID';
  END IF;
  IF l_lvl_rnk>=6 THEN
     x_org_ref_tbls:=x_org_ref_tbls || ',DDR_R_ORG ORGF';
     --x_itm_ref_joins:=x_itm_ref_joins||' ';
  END IF;
  IF l_lvl_rnk>=7 THEN
     x_org_ref_tbls:=x_org_ref_tbls || ',DDR_R_RTL_CLSTR ORGG,DDR_R_RTL_CLSTR_RTL_ASSC ORGH';
     x_org_ref_joins:=x_org_ref_joins||' AND ORGE.ORG_CD = ORGH.RTL_ORG_CD';
  END IF;
  IF p_org_dim_lvl_cd IS NOT NULL THEN
    get_org_ref_join(l_lvl_rnk,x_org_where_clus,x_return_status,x_msg_count,x_msg_data);
    x_org_where_clus:= x_org_where_clus || '=''' || p_org_lvl_val||'''';
  END IF;
  -- END CASE;
  EXCEPTION
  WHEN OTHERS THEN
        x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
        x_msg_count:=1;
        x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
  END get_org_hrchy_clauses;

  PROCEDURE get_org_ref_join(p_lvl_rnk         IN  NUMBER,
                             x_ref_join        OUT NOCOPY  VARCHAR2,
                             x_return_status   OUT NOCOPY  VARCHAR2,
                             x_msg_count       OUT NOCOPY  VARCHAR2,
                             x_msg_data        OUT NOCOPY  VARCHAR2)
  IS
  BEGIN
      CASE p_lvl_rnk
      --bug 6921259 change start
      WHEN 0 THEN
           x_ref_join:=' X.INV_LOC_CD ';
      --bug 6921259 change end
      WHEN 1 THEN
           x_ref_join:=' ORGA.BSNS_UNIT_CD ';
      WHEN 5 THEN
           x_ref_join:=' ORGE.CHAIN_CD ';
      WHEN 6 THEN
           x_ref_join:=' ORGF.ORG_CD ';
      WHEN 7 THEN
           x_ref_join:=' ORGG.CLSTR_CD ';
      END CASE;
 EXCEPTION
 WHEN OTHERS THEN
      x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
      x_msg_count:=1;
      x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
 END  get_org_ref_join;

 PROCEDURE get_time_hrchy_clauses(p_time_dim_lvl_cd IN VARCHAR2,
                                  p_time_lvl_val    IN VARCHAR2,
                                  p_exp_time_level  IN VARCHAR2,
                                  p_fact_code       IN VARCHAR2,
                                  p_org_cd          IN VARCHAR2,
                                  x_return_status   OUT NOCOPY  VARCHAR2,
                                  x_msg_count       OUT NOCOPY  VARCHAR2,
                                  x_msg_data        OUT NOCOPY  VARCHAR2,
                                  x_time_ref_tbls   OUT NOCOPY  VARCHAR2,
                                  x_time_ref_joins  OUT NOCOPY  VARCHAR2,
                                  x_time_where_clus OUT NOCOPY  VARCHAR2)
 IS
   l_lvl_rnk NUMBER:=null;
   l_hrchy_lvl_name VARCHAR2(50):=null;
 BEGIN
   -- CASE p_fact_code
   -- for RETAIL SALE RETURN ITEM DAY fact
   --WHEN ddr_webservices_constants.g_rsrid_cd THEN
      --to get the time hierarchy level name(GREGORIAN TIME OR BUSINESS TIME)
   IF p_time_dim_lvl_cd IS NOT NULL THEN
       SELECT hrchy_lvl_name INTO l_hrchy_lvl_name FROM DDR_WS_METADATA WHERE
       hrchy_lvl_cd=p_time_dim_lvl_cd;
       get_hrchy_lvl(l_hrchy_lvl_name,p_time_dim_lvl_cd,l_lvl_rnk,x_return_status,x_msg_count,x_msg_data);
   ELSIF p_exp_time_level IS NOT NULL THEN
       SELECT hrchy_lvl_name INTO l_hrchy_lvl_name FROM DDR_WS_METADATA WHERE
       hrchy_lvl_cd=p_exp_time_level;
       get_hrchy_lvl(l_hrchy_lvl_name,p_exp_time_level,l_lvl_rnk,x_return_status,x_msg_count,x_msg_data);
   END IF;
   IF l_lvl_rnk IS NULL THEN
     RETURN;
   END IF;
   CASE l_hrchy_lvl_name
      WHEN 'GREGORIAN TIME' THEN
          IF l_lvl_rnk>=1 THEN
             x_time_ref_tbls:=',DDR_R_DAY TDAY';
             IF p_fact_code = ddr_webservices_constants.g_pp_cd THEN
             	x_time_ref_joins:=' AND  TDAY.CLNDR_DT BETWEEN X.PRMTN_FROM_DT AND X.PRMTN_TO_DT';
             ELSE
             	x_time_ref_joins:=' AND  X.DAY_CD = TDAY.DAY_CD';
             END IF;
          END IF;
          IF l_lvl_rnk>=3 THEN
             x_time_ref_tbls:=x_time_ref_tbls || ',DDR_R_CLNDR_MNTH TCA';
             x_time_ref_joins:=x_time_ref_joins||' AND TDAY.CLNDR_MNTH_ID = TCA.CLNDR_MNTH_ID';
          END IF;
          IF l_lvl_rnk>=5 THEN
             x_time_ref_tbls:=x_time_ref_tbls || ',DDR_R_CLNDR_QTR TCB,DDR_R_CLNDR_YR TCC';
             x_time_ref_joins:=x_time_ref_joins||' AND TCA.CLNDR_QTR_ID=TCB.CLNDR_QTR_ID  AND TCB.CLNDR_YR_ID = TCC.CLNDR_YR_ID';
          END IF;
          IF p_time_dim_lvl_cd IS NOT NULL THEN
             get_time_ref_join(l_hrchy_lvl_name,l_lvl_rnk,x_time_where_clus,x_return_status,x_msg_count,x_msg_data);
             x_time_where_clus:= x_time_where_clus || '=''' ||
             p_time_lvl_val||'''';
          END IF;
      WHEN 'BUSINESS TIME' THEN
          IF l_lvl_rnk>=1 THEN
               x_time_ref_tbls:=',DDR_R_CLNDR TCLNDR,DDR_R_DAY TDAY,DDR_R_BASE_DAY TBA';

               IF p_fact_code = ddr_webservices_constants.g_pp_cd THEN
               	x_time_ref_joins:=' AND TDAY.CLNDR_DT BETWEEN X.PRMTN_FROM_DT AND X.PRMTN_TO_DT AND TDAY.DAY_CD = TBA.DAY_CD '
	               ||' AND TBA.CLNDR_TYP=''BSNS'' AND TBA.CLNDR_CD=TCLNDR.CLNDR_CD AND TCLNDR.CLNDR_TYP=''BSNS'''
	               ||' AND TCLNDR.ORG_CD='''||p_org_cd||'''';
               ELSE
	             	x_time_ref_joins:=' AND X.DAY_CD = TDAY.DAY_CD AND TDAY.DAY_CD = TBA.DAY_CD '
	               ||' AND TBA.CLNDR_TYP=''BSNS'' AND TBA.CLNDR_CD=TCLNDR.CLNDR_CD AND TCLNDR.CLNDR_TYP=''BSNS'''
	               ||' AND TCLNDR.ORG_CD='''||p_org_cd||'''';
	             END IF;
          END IF;
          IF l_lvl_rnk>=2 THEN
               x_time_ref_tbls:=x_time_ref_tbls || ',DDR_R_BSNS_WK TBB';
               x_time_ref_joins:=x_time_ref_joins||' AND TBA.WK_ID = TBB.BSNS_WK_ID';
          END IF;
          IF l_lvl_rnk>=3 THEN
               x_time_ref_tbls:=x_time_ref_tbls || ',DDR_R_BSNS_MNTH TBC';
               x_time_ref_joins:=x_time_ref_joins||' AND TBB.BSNS_MNTH_ID = TBC.BSNS_MNTH_ID';
          END IF;
          IF l_lvl_rnk>=4 THEN
              x_time_ref_tbls:=x_time_ref_tbls || ',DDR_R_BSNS_QTR TBD';
              x_time_ref_joins:=x_time_ref_joins||' AND TBC.BSNS_QTR_ID = TBD.BSNS_QTR_ID';
          END IF;
          IF l_lvl_rnk>=5 THEN
              x_time_ref_tbls:=x_time_ref_tbls || ',DDR_R_BSNS_YR TBE';
              x_time_ref_joins:=x_time_ref_joins||' AND TBD.BSNS_YR_ID = TBE.BSNS_YR_ID';
          END IF;
          IF p_time_dim_lvl_cd IS NOT NULL THEN
             get_time_ref_join(l_hrchy_lvl_name,l_lvl_rnk,x_time_where_clus,x_return_status,x_msg_count,x_msg_data);
             x_time_where_clus:= x_time_where_clus || '=''' ||
             p_time_lvl_val||'''';
          END IF;

      END CASE;
     -- END CASE;
 EXCEPTION
      WHEN OTHERS THEN
          x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
          x_msg_count:=1;
          x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
 END get_time_hrchy_clauses;

 PROCEDURE get_time_ref_join(p_hrchy_name      IN  VARCHAR2,
                             p_lvl_rnk         IN  NUMBER,
                             x_ref_join        OUT NOCOPY  VARCHAR2,
                             x_return_status   OUT NOCOPY  VARCHAR2,
                             x_msg_count       OUT NOCOPY  VARCHAR2,
                             x_msg_data        OUT NOCOPY  VARCHAR2)
 IS
 BEGIN
    CASE p_hrchy_name
       WHEN 'GREGORIAN TIME' THEN
           CASE p_lvl_rnk
                WHEN 1 THEN
                   x_ref_join:=' X.DAY_CD ';
                WHEN 3 THEN
                   x_ref_join:=' TCA.MNTH_CD ';
                WHEN 5 THEN
                   x_ref_join:=' TCC.YR_CD';
                END CASE;
       WHEN 'BUSINESS TIME' THEN
           CASE p_lvl_rnk
                WHEN 1 THEN
                   x_ref_join:=' X.DAY_CD';
                WHEN 2 THEN
                   x_ref_join:=' TBB.WK_CD';
                WHEN 3 THEN
                   x_ref_join:=' TBC.MNTH_CD ';
                WHEN 4 THEN
                   x_ref_join:=' TBD.QTR_CD ';
                WHEN 5 THEN
                   --bug 6928308 change start
                   x_ref_join:=' TBE.YR_CD ';
                   --bug 6928308 change end
                END CASE;
           END CASE;
 EXCEPTION
 WHEN OTHERS THEN
        x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
        x_msg_count:=1;
        x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
 END get_time_ref_join;


 PROCEDURE get_loc_hrchy_clauses(p_loc_dim_lvl_cd  IN VARCHAR2,
                                 p_loc_lvl_val     IN VARCHAR2,
                                 p_exp_loc_level   IN VARCHAR2,
                                 p_org_dim_lvl_cd  IN VARCHAR2,
                                 p_fact_code       IN VARCHAR2,
                                 x_return_status   OUT NOCOPY  VARCHAR2,
                                 x_msg_count       OUT NOCOPY  VARCHAR2,
                                 x_msg_data        OUT NOCOPY  VARCHAR2,
                                 x_loc_ref_tbls    OUT NOCOPY  VARCHAR2,
                                 x_loc_ref_joins   OUT NOCOPY  VARCHAR2,
                                 x_loc_where_clus  OUT NOCOPY  VARCHAR2)
 IS
    l_lvl_rnk NUMBER:=null;
    l_org_lvl_rnk NUMBER:=null;
 BEGIN
    -- CASE p_fact_code
    -- for RETAIL SALE RETURN ITEM DAY fact
    --WHEN ddr_webservices_constants.g_rsrid_cd THEN
    IF p_loc_dim_lvl_cd IS NOT NULL THEN
    	get_hrchy_lvl('LOCATION',p_loc_dim_lvl_cd,l_lvl_rnk,x_return_status,x_msg_count,x_msg_data);
    ELSIF p_exp_loc_level IS NOT NULL THEN
      get_hrchy_lvl('LOCATION',p_exp_loc_level,l_lvl_rnk,x_return_status,x_msg_count,x_msg_data);
    END IF;
    IF l_lvl_rnk IS NULL THEN
        RETURN;
    END IF;
    IF l_lvl_rnk>=1 THEN
      --check if p_org_dim_lvl_cd is not specified, the include DSR_R_ORG_BSNS_UNIT ORGA in FROM clause
      IF p_org_dim_lvl_cd IS NULL THEN
         x_loc_ref_tbls:= ',DDR_R_ORG_BSNS_UNIT ORGA';
         x_loc_ref_joins:=' AND X.ORG_BSNS_UNIT_ID = ORGA.ORG_BSNS_UNIT_ID';
      END IF;
      x_loc_ref_tbls:= x_loc_ref_tbls|| ',DDR_R_ADDR_LOC LOCA,DDR_R_CITY LOCB';
      x_loc_ref_joins:=x_loc_ref_joins||' AND ORGA.ADDR_LOC_ID = LOCA.ADDR_LOC_ID(+) AND LOCA.CITY_CD = LOCB.CITY_CD(+)';
    END IF;
    IF l_lvl_rnk>=2 THEN
      x_loc_ref_tbls:=x_loc_ref_tbls || ',DDR_R_STATE LOCC';
      x_loc_ref_joins:=x_loc_ref_joins||' AND LOCB.STATE_CD = LOCC.STATE_CD(+)';
    END IF;
    IF l_lvl_rnk>=3 THEN
      x_loc_ref_tbls:=x_loc_ref_tbls || ',DDR_R_CNTRY LOCD';
      x_loc_ref_joins:=x_loc_ref_joins||' AND LOCC.CNTRY_CD = LOCD.CNTRY_CD(+)';
    END IF;
    IF p_loc_dim_lvl_cd IS NOT NULL THEN
        get_loc_ref_join(l_lvl_rnk,x_loc_where_clus,x_return_status,x_msg_count,x_msg_data);
        x_loc_where_clus:= x_loc_where_clus || '=''' || p_loc_lvl_val||'''';
    END IF;
    -- END CASE;
 EXCEPTION
 WHEN OTHERS THEN
        x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
        x_msg_count:=1;
        x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
 END get_loc_hrchy_clauses;

 PROCEDURE get_loc_ref_join(p_lvl_rnk  IN NUMBER,
                            x_ref_join OUT NOCOPY  VARCHAR2,
                            x_return_status   OUT NOCOPY  VARCHAR2,
                            x_msg_count       OUT NOCOPY  VARCHAR2,
                            x_msg_data        OUT NOCOPY  VARCHAR2)
 IS
 BEGIN
    CASE p_lvl_rnk
         WHEN 1 THEN
            x_ref_join:=' LOCB.CITY_CD ';
         WHEN 2 THEN
            x_ref_join:=' LOCC.STATE_CD ';
         WHEN 3 THEN
            x_ref_join:=' LOCD.CNTRY_CD ';
         END CASE;
 EXCEPTION
 WHEN OTHERS THEN
        x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
        x_msg_count:=1;
        x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:'||sqlerrm;
 END get_loc_ref_join;

 PROCEDURE get_hrchy_lvl(p_hrchy_lvl_name  IN VARCHAR2,
                         p_hrchy_lvl_cd    IN VARCHAR2,
                         x_hrchy_lvl       OUT NOCOPY  NUMBER,
                         x_return_status   OUT NOCOPY  VARCHAR2,
                         x_msg_count       OUT NOCOPY  VARCHAR2,
                         x_msg_data        OUT NOCOPY  VARCHAR2)
 IS
    l_hrchy_lvl NUMBER:=null;
 BEGIN
    SELECT lvl_rnk INTO l_hrchy_lvl FROM DDR_WS_METADATA WHERE HRCHY_LVL_CD=p_hrchy_lvl_cd AND hrchy_lvl_name=p_hrchy_lvl_name;
    -- DBMS_OUTPUT.PUT_LINE('p_hrchy_lvl_name='||p_hrchy_lvl_name||' ,p_hrchy_lvl_cd='||p_hrchy_lvl_cd||' ,x_hrchy_lvl='||l_hrchy_lvl);
    x_hrchy_lvl:=l_hrchy_lvl;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
            x_return_status := ddr_webservices_constants.g_ret_sts_error;
            x_msg_count := 1;
            x_msg_data := 'No data found for hierarchy code:'|| p_hrchy_lvl_cd ||'. Error Code' ||sqlcode||' Error message:'||sqlerrm;
 END get_hrchy_lvl;

 --Bug 6880404 change start
 PROCEDURE get_other_join_conditions(p_fact_code VARCHAR2,
                                     x_return_status   OUT NOCOPY  VARCHAR2,
                                     x_msg_count       OUT NOCOPY  VARCHAR2,
                                     x_msg_data        OUT NOCOPY  VARCHAR2,
                                     x_oth_join_codn   OUT NOCOPY  VARCHAR2)
 IS
   l_join_cndn VARCHAR2(32767):=NULL;
   l_max_frcst_date DATE:=null;
 BEGIN
  --if the fact code is for forcest sales table, then join condition to fetch
  --the latest forcest version
  IF p_fact_code= ddr_webservices_constants.g_sfid_cd THEN
    --bug 6905930 change start
    l_join_cndn:= ' AND (x.frcst_vrsn,x.mfg_org_cd,x.rtl_org_cd,
x.org_bsns_unit_id, x.day_cd, x.glbl_item_id, x.rtl_sku_item_id) IN(SELECT
MAX(frcst_vrsn),  mfg_org_cd,  rtl_org_cd,  org_bsns_unit_id,  day_cd,
glbl_item_id,  rtl_sku_item_id FROM ddr_b_sls_frcst_item_day GROUP BY
mfg_org_cd,  rtl_org_cd,  org_bsns_unit_id,  day_cd,  glbl_item_id,
rtl_sku_item_id)';
   --bug 6905930 change end
  END IF;
 x_oth_join_codn := l_join_cndn;
 EXCEPTION
  WHEN NO_DATA_FOUND THEN
        x_return_status := ddr_webservices_constants.g_ret_sts_error;
        x_msg_count := 1;
        x_msg_data := 'No data found. Error Code' ||sqlcode||' Error
message:'||sqlerrm;
  WHEN OTHERS THEN
        x_return_status:=ddr_webservices_constants.g_ret_sts_unexp_error;
        x_msg_count:=1;
        x_msg_data:='Unexpected Error. Error code:'||sqlcode||' Error message:
'||sqlerrm;
 END get_other_join_conditions;
 --Bug 6880404 change end

END ddr_webservices_pub;

/
