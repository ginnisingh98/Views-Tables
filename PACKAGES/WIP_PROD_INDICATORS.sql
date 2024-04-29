--------------------------------------------------------
--  DDL for Package WIP_PROD_INDICATORS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_PROD_INDICATORS" AUTHID CURRENT_USER AS
/* $Header: wippinds.pls 115.14 2003/12/09 01:37:54 digupta ship $ */

    /* Public Procedures  */

    PROCEDURE Load_Summary_Info(
            errbuf          OUT NOCOPY VARCHAR2,
            retcode         OUT NOCOPY VARCHAR2,
            p_date_from     IN  VARCHAR2,
            p_date_to       IN  VARCHAR2);

    PROCEDURE Populate_Summary_Table (
            p_group_id          IN  NUMBER,
            p_organization_id   IN  NUMBER,
            p_date_from     IN  DATE,
            p_date_to       IN  DATE,
            p_department_id     IN  NUMBER,
            p_resource_id       IN  NUMBER,
            p_userid        IN  NUMBER,
            p_applicationid     IN  NUMBER,
            p_errnum        OUT NOCOPY NUMBER,
            p_errmesg       OUT NOCOPY VARCHAR2 );

    PROCEDURE Populate_Efficiency (
            p_group_id          IN  NUMBER,
            p_organization_id   IN  NUMBER,
            p_date_from     IN  DATE,
            p_date_to       IN  DATE,
            p_department_id     IN  NUMBER,
            p_resource_id       IN  NUMBER,
            p_userid        IN  NUMBER,
            p_applicationid     IN  NUMBER,
            p_errnum        OUT NOCOPY NUMBER,
            p_errmesg       OUT NOCOPY VARCHAR2 );


    PROCEDURE Populate_Utilization (
            p_group_id          IN  NUMBER,
            p_organization_id   IN  NUMBER,
            p_date_from         IN  DATE,
            p_date_to           IN  DATE,
            p_department_id     IN  NUMBER,
            p_resource_id       IN  NUMBER,
            p_userid            IN  NUMBER,
            p_applicationid     IN  NUMBER,
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2,
            p_sfcb              IN  NUMBER DEFAULT NULL );


    PROCEDURE Populate_Yield (
            p_group_id          IN  NUMBER,
            p_organization_id   IN  NUMBER,
            p_date_from         IN  DATE,
            p_date_to           IN  DATE,
            p_department_id     IN  NUMBER,
            p_resource_id       IN  NUMBER,
            p_userid            IN  NUMBER,
            p_applicationid     IN  NUMBER,
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2 );


    PROCEDURE Calc_Eff_Applied_Units (
            p_errmesg           OUT NOCOPY VARCHAR2,
            p_errnum            OUT NOCOPY NUMBER,
            p_group_id          IN NUMBER);


    PROCEDURE Calculate_Std_Quantity (
            p_group_id      IN  NUMBER,
            p_organization_id   IN  NUMBER,
            p_date_from     IN  DATE,
            p_date_to       IN  DATE,
            p_department_id     IN  NUMBER,
            p_indicator     IN  NUMBER );


     PROCEDURE Calculate_Std_Units (
            p_group_id      IN  NUMBER,
            p_resource_id       IN  NUMBER,
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2,
            p_indicator     IN  NUMBER );


    PROCEDURE Calculate_Total_Quantity (
            p_group_id      IN  NUMBER,
            p_organization_id   IN  NUMBER,
            p_date_from     IN  DATE,
            p_date_to       IN  DATE,
            p_department_id     IN  NUMBER);


    PROCEDURE Calculate_Scrap_Quantity (
            p_group_id  IN  NUMBER,
            p_organization_id IN NUMBER,
            p_date_from     IN  DATE,
            p_date_to       IN  DATE,
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2 );


    PROCEDURE Delete_Temp_Info  (
            p_group_id          IN  NUMBER);

    PROCEDURE Populate_Assy_Yield (
            p_organization_id   IN  NUMBER,
            p_date_from         IN  DATE,
            p_date_to           IN  DATE,
            p_userid            IN  NUMBER,
            p_applicationid     IN  NUMBER,
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2 );

    PROCEDURE Populate_Productivity (
            p_group_id          IN  NUMBER,
            p_organization_id   IN  NUMBER,
            p_date_from         IN  DATE,
            p_date_to           IN  DATE,
            p_department_id     IN  NUMBER,
            p_resource_id       IN  NUMBER,
            p_userid            IN  NUMBER,
            p_applicationid     IN  NUMBER,
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2);

    PROCEDURE Populate_Resource_Load (
            p_group_id          IN  NUMBER,
            p_organization_id   IN  NUMBER,
            p_date_from         IN  DATE,
            p_date_to           IN  DATE,
            p_department_id     IN  NUMBER,
            p_resource_id       IN  NUMBER,
            p_userid            IN  NUMBER,
            p_applicationid     IN  NUMBER,
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2);

    PROCEDURE Calculate_Resource_Avail(
            p_organization_id   IN  NUMBER,
            p_date_from         IN  DATE,
            p_date_to           IN  DATE,
            p_department_id     IN  NUMBER,
            p_resource_id       IN  NUMBER,
            p_errnum            OUT NOCOPY NUMBER,
            p_errmesg           OUT NOCOPY VARCHAR2);

    FUNCTION get_Workday_Ratio (
            p_resource_id      IN  NUMBER,
            p_organization_id  IN  NUMBER,
            p_start_date       IN  DATE,
            p_completion_date  IN  DATE,
            p_transaction_date IN  DATE)
        RETURN NUMBER ;


    PROCEDURE Populate_Denormalize_Data (
            p_errnum IN OUT NOCOPY NUMBER,
            p_errmesg IN OUT NOCOPY VARCHAR2);


    PROCEDURE denormalize_item_dimension (
            p_table_name IN VARCHAR2,
            p_errnum IN OUT NOCOPY NUMBER,
            p_errmesg IN OUT NOCOPY VARCHAR2);


    PROCEDURE denormalize_time_dimension (
            p_table_name IN VARCHAR2,
            p_errnum IN OUT NOCOPY NUMBER,
            p_errmesg IN OUT NOCOPY VARCHAR2);


    PROCEDURE denormalize_org_dimension (
            p_table_name IN VARCHAR2,
            p_errnum IN OUT NOCOPY NUMBER,
            p_errmesg IN OUT NOCOPY VARCHAR2);

    PROCEDURE denormalize_geo_dimension (
            p_table_name IN VARCHAR2,
            p_errnum IN OUT NOCOPY NUMBER,
            p_errmesg IN OUT NOCOPY VARCHAR2);


    PRAGMA RESTRICT_REFERENCES (get_Workday_Ratio, WNDS, WNPS);


    /* Some constants  -- For a bug fix*/
    -- Since might be redefining tables, catch that exception
    object_already_defined EXCEPTION;
    -- The associated error number is -995
    PRAGMA EXCEPTION_INIT (object_already_defined, -955);


    -- First query rewrite.
    -- All we do here is decompose the wip_indicators_temp table
    -- into 3 separate tables based on whether the records have
    -- indicator_type = WIP_EFFICIENCY, WIP_UTILIZATION, WIP_YIELD
    PROCEDURE simple_decomp (
            p_group_id IN NUMBER);


END WIP_PROD_INDICATORS;

 

/
