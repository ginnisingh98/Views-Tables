--------------------------------------------------------
--  DDL for Package CST_ACCRUALWRITEOFFREPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_ACCRUALWRITEOFFREPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: CSTVAWOS.pls 120.2 2005/10/18 04:38:10 nejain noship $ */

/*==============================================================================*/
--      API name        : Generate_WriteOffReportXml
--      Type            : Private
--      Function        : Generate XML Data for Accrual Write Off Report
--      Pre-reqs        : None.
--      Parameters      :
--                      : p_Chart_of_accounts_id        IN NUMBER     Required
--                      : p_title                       IN VARCHAR2
--                      : p_bal_segment_from            IN VARCHAR2
--                      : p_bal_segment_to              IN VARCHAR2
--                      : p_from_write_off_date         IN VARCHAR2
--                      : p_to_write_off_date           IN VARCHAR2
--                      : p_from_amount                 IN NUMBER
--                      : p_to_amount                   IN NUMBER
--                      : p_reason                      IN NUMBER
--                      : p_comments                    IN VARCHAR2
--                      : p_sort_by                     IN VARCHAR2
--
--      OUT             :
--                      : errcode                       OUT VARCHAR2
--                      : errno                         OUT NUMBER
--      Version         : Current version               1.0
--                      : Initial version               1.0
--      Notes           : This Procedure is called by the Accrual Write-Off
--                        Report. This is the wrapper procedure that
--                        calls the other procedures to generate XML data
--                        according to report parameters.
-- End of comments
/*==============================================================================*/

PROCEDURE Generate_WriteOffReportXml (
                errcode                 OUT NOCOPY      VARCHAR2,
                err_code                OUT NOCOPY      NUMBER,

                p_Chart_of_accounts_id  IN              NUMBER,
                p_bal_seg_val           IN              NUMBER,
                p_title                 IN              VARCHAR2,
                p_bal_segment_from      IN              VARCHAR2,
                p_bal_segment_to        IN              VARCHAR2,
                p_from_write_off_date   IN              VARCHAR2,
                p_to_write_off_date     IN              VARCHAR2,
                p_from_amount           IN              NUMBER,
                p_to_amount             IN              NUMBER,
                p_reason                IN              NUMBER,
                p_comments              IN              VARCHAR2,
                p_sort_by               IN              VARCHAR2  );

/*==============================================================================*/
--      API name        : add_parameters
--      Type            : Private
--      Function        : Generate XML data for Parameters and append it to
--                        output
--      Pre-reqs        : None.
--      Parameters      :
--                      : p_api_version           IN            NUMBER
--                      : p_init_msg_list         IN            VARCHAR2
--                      : p_validation_level      IN            NUMBER
--                      : i_title                 IN            VARCHAR2
--                      : i_from_write_off_date   IN            VARCHAR2
--                      : i_to_write_off_date     IN            VARCHAR2
--                      : i_reason                IN            NUMBER
--                      : i_comments              IN            VARCHAR2
--                      : i_from_amount           IN            NUMBER
--                      : i_to_amount             IN            NUMBER
--                      : i_sort_by               IN            VARCHAR2
--                      : i_bal_segment_from      IN            VARCHAR2
--                      : i_bal_segment_to        IN            VARCHAR2
--
--     IN OUT           :
--                      : x_xml_doc               IN OUT NOCOPY CLOB
--
--     OUT              :
--                      : x_return_status         OUT           VARCHAR2
--                      : x_msg_count             OUT           NUMBER
--                      : x_msg_data              OUT           VARCHAR2
--
--      Version         : Current version   1.0
--                      : Initial version   1.0
--      Notes           : This Procedure is called by CST_AccrualWriteOffReport_PVT
--                        procedure. The procedure generates XML data for the
--                        report parameters and appends it to the report output.
-- End of comments
/*==============================================================================*/

PROCEDURE Add_Parameters
                (p_api_version          IN              NUMBER,
                p_init_msg_list         IN              VARCHAR2 ,
                p_validation_level      IN              NUMBER,

                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                i_title                 IN              VARCHAR2,
                i_from_write_off_date   IN              DATE,
                i_to_write_off_date     IN              DATE,
                i_reason                IN              NUMBER,
                i_comments              IN              VARCHAR2,
                i_from_amount           IN              NUMBER,
                i_to_amount             IN              NUMBER,
                i_sort_by               IN              VARCHAR2,
                i_bal_segment_from      IN              VARCHAR2 ,
                i_bal_segment_to        IN              VARCHAR2 ,

                x_xml_doc               IN OUT NOCOPY   CLOB);

/*==============================================================================*/
--      API name        : Add_WriteOffData
--      Type            : Private
--      Function        : Generate XML data from sql query and append it to
--                        output
--      Pre-reqs        : None.
--      Parameters      :
--                      : p_api_version           IN            NUMBER
--                      : p_init_msg_list         IN            VARCHAR2
--                      : p_validation_level      IN            NUMBER
--                      : i_title                 IN            VARCHAR2
--                      : i_from_write_off_date   IN            VARCHAR2
--                      : i_to_write_off_date     IN            VARCHAR2
--                      : i_reason                IN            NUMBER
--                      : i_comments              IN            VARCHAR2
--                      : i_from_amount           IN            NUMBER
--                      : i_to_amount             IN            NUMBER
--                      : i_sort_by               IN            VARCHAR2
--                      : i_bal_segment_from      IN            VARCHAR2
--                      : i_bal_segment_to        IN            VARCHAR2
--                      : x_xml_doc               IN OUT NOCOPY CLOB
--
--                      : x_return_status         OUT           VARCHAR2
--                      : x_msg_count             OUT           NUMBER
--                      : x_msg_data              OUT           VARCHAR2
--      Version         : Current version         1.0
--                      : Initial version         1.0
--      Notes           : This Procedure is called by CST_AccrualWriteOffReport_PVT
--                        procedure. The procedure generates XML data from sql query
--                        and appends it to the report output
-- End of comments
/*==============================================================================*/

PROCEDURE Add_WriteOffData
                (p_api_version          IN              NUMBER,
                p_init_msg_list         IN              VARCHAR2 ,
                p_validation_level      IN              NUMBER  ,

                x_return_status         OUT NOCOPY      VARCHAR2,
                x_msg_count             OUT NOCOPY      NUMBER,
                x_msg_data              OUT NOCOPY      VARCHAR2,

                i_title                 IN              VARCHAR2,
                i_from_write_off_date   IN              DATE,
                i_to_write_off_date     IN              DATE,
                i_reason                IN              NUMBER,
                i_comments              IN              VARCHAR2,
                i_from_amount           IN              NUMBER,
                i_to_amount             IN              NUMBER,
                i_sort_by               IN              VARCHAR2,
                i_bal_segment_from      IN              VARCHAR2 ,
                i_bal_segment_to        IN              VARCHAR2 ,

                x_xml_doc               IN OUT NOCOPY   CLOB);

END CST_AccrualWriteOffReport_PVT ;

 

/
