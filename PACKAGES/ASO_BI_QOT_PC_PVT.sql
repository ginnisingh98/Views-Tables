--------------------------------------------------------
--  DDL for Package ASO_BI_QOT_PC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_BI_QOT_PC_PVT" AUTHID CURRENT_USER AS
/* $Header: asovbiqpcs.pls 120.2 2005/09/16 04:41:47 kedukull noship $*/

PROCEDURE PCAll(p_conv_rate      IN NUMBER
               ,p_record_type_id IN NUMBER
               ,p_sg_id_num      IN NUMBER
               ,p_sr_id_num      IN NUMBER
               ,p_asof_date      IN DATE
               ,p_priorasof_date IN DATE
               ,p_fdcp_date      IN DATE
               ,p_fdpp_date      IN DATE
               ,p_fdcp_date_j    IN NUMBER
               ,p_fdpp_date_j    IN NUMBER);

PROCEDURE PCSPrA(p_asof_date      IN DATE
                ,p_priorasof_date IN DATE
                ,p_fdcp_date      IN DATE
                ,p_fdpp_date      IN DATE
                ,p_conv_rate      IN NUMBER
                ,p_record_type_id IN NUMBER
                ,p_sg_id_num      IN NUMBER
                ,p_sr_id_num      IN NUMBER
                ,p_fdcp_date_j    IN NUMBER
                ,p_fdpp_date_j    IN NUMBER
                ,p_product_cat    IN NUMBER);

PROCEDURE PCAPrS(p_asof_date      IN DATE
                ,p_priorasof_date IN DATE
                ,p_fdcp_date      IN DATE
                ,p_fdpp_date      IN DATE
                ,p_conv_rate      IN NUMBER
                ,p_record_type_id IN NUMBER
                ,p_sg_id_num      IN NUMBER
                ,p_sr_id_num      IN NUMBER
                ,p_fdcp_date_j    IN NUMBER
                ,p_fdpp_date_j    IN NUMBER
                ,p_product_id     IN VARCHAR2);

PROCEDURE PCSPrS(p_asof_date      IN DATE
                ,p_priorasof_date IN DATE
                ,p_fdcp_date      IN DATE
                ,p_fdpp_date      IN DATE
                ,p_conv_rate      IN NUMBER
                ,p_record_type_id IN NUMBER
                ,p_sg_id_num      IN NUMBER
                ,p_sr_id_num      IN NUMBER
                ,p_fdcp_date_j    IN NUMBER
                ,p_fdpp_date_j    IN NUMBER
                ,p_product_cat    IN NUMBER
                ,p_product_id     IN VARCHAR2);

PROCEDURE PCAllProd(p_conv_rate      IN NUMBER
                   ,p_record_type_id IN NUMBER
                   ,p_sg_id_num      IN NUMBER
                   ,p_sr_id_num      IN NUMBER
                   ,p_fdcp_date_j    IN NUMBER
                   ,p_fdpp_date_j    IN NUMBER
                   ,p_asof_date      IN DATE
                   ,p_priorasof_date IN DATE
                   ,p_fdcp_date      IN DATE
                   ,p_fdpp_date      IN DATE);

PROCEDURE PCSPrAProd(p_asof_date      IN DATE
                    ,p_priorasof_date IN DATE
                    ,p_fdcp_date      IN DATE
                    ,p_fdpp_date      IN DATE
                    ,p_conv_rate      IN NUMBER
                    ,p_record_type_id IN NUMBER
                    ,p_sg_id_num      IN NUMBER
                    ,p_sr_id_num      IN NUMBER
                    ,p_fdcp_date_j    IN NUMBER
                    ,p_fdpp_date_j    IN NUMBER
                    ,p_product_cat    IN NUMBER);

PROCEDURE PCAPrSProd(p_asof_date      IN DATE
                    ,p_priorasof_date IN DATE
                    ,p_fdcp_date      IN DATE
                    ,p_fdpp_date      IN DATE
                    ,p_conv_rate      IN NUMBER
                    ,p_record_type_id IN NUMBER
                    ,p_sg_id_num      IN NUMBER
                    ,p_sr_id_num      IN NUMBER
                    ,p_fdcp_date_j    IN NUMBER
                    ,p_fdpp_date_j    IN NUMBER
                    ,p_product_id     IN VARCHAR2);

PROCEDURE PCSPrSProd(p_asof_date      IN DATE
                    ,p_priorasof_date IN DATE
                    ,p_fdcp_date      IN DATE
                    ,p_fdpp_date      IN DATE
                    ,p_conv_rate      IN NUMBER
                    ,p_record_type_id IN NUMBER
                    ,p_sg_id_num      IN NUMBER
                    ,p_sr_id_num      IN NUMBER
                    ,p_fdcp_date_j    IN NUMBER
                    ,p_fdpp_date_j    IN NUMBER
                    ,p_product_cat    IN NUMBER
                    ,p_product_id     IN VARCHAR2);
END;

 

/
