--------------------------------------------------------
--  DDL for Package CSD_RETURNS_BI_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_RETURNS_BI_UTIL" AUTHID CURRENT_USER AS
    /* $Header: csdurbis.pls 120.0.12010000.1 2010/04/14 23:21:29 swai noship $ */

    /*--------------------------------------------------------*/
    /* function name: CONVERT_INV_UOM                         */
    /* description : function used to convert quantities from */
    /*               one inventory UOM to another             */
    /* Called from : Depot Repair Returns BI dashboard        */
    /* Input Parm  :                                          */
    /*   p_qty               NUMBER    qty to convert         */
    /*   p_from_uom          VARCHAR2  From UOM code          */
    /*   p_to_uom            VARCHAR2  To UOM code            */
    /*   p_error_val         NUMBER    Value to return if qty */
    /*                                 is null or conversion  */
    /*                                 errored out            */
    /* Output:                                                */
    /*        NUMBER  Converted currency amount               */
    /*                Returns null if there is an error       */
    /* Change Hist :                                          */
    /*--------------------------------------------------------*/
    FUNCTION CONVERT_INV_UOM (p_qty       IN NUMBER,
                              p_from_uom  IN VARCHAR2,
                              p_to_uom    IN VARCHAR2,
                              p_error_val IN NUMBER) RETURN NUMBER;


    /*--------------------------------------------------------*/
    /* function name: CONVERT_CURRENCY                        */
    /* description : function used to convert currency -      */
    /* Called from : Depot Repair Returns BI dashboard        */
    /* Input Parm  :                                          */
    /*   p_amount            NUMBER    Amount to convert      */
    /*   p_from_currency     VARCHAR2  From currency code     */
    /*   p_to_currency       VARCHAR2  To Currency code       */
    /*   p_error_val         NUMBER    Value to return if amt */
    /*                                 is null or conversion  */
    /*                                 errored out            */
    /* Output:                                                */
    /*        NUMBER  Converted currency amount               */
    /*                Returns null if there is an error       */
    /* Change Hist :                                          */
    /*--------------------------------------------------------*/
    FUNCTION CONVERT_CURRENCY( p_amount          IN   NUMBER,
                               p_from_currency   IN   VARCHAR2,
                               p_to_currency     IN   VARCHAR2,
                               p_conversion_date IN   DATE,
                               p_error_val       IN   NUMBER) RETURN NUMBER;

END CSD_RETURNS_BI_UTIL;

/
