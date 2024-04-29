--------------------------------------------------------
--  DDL for Package AP_WEB_AMOUNT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_AMOUNT_UTIL" AUTHID CURRENT_USER AS
/* $Header: apwamtus.pls 120.5 2006/07/14 09:41:22 sbalaji noship $ */

  procedure get_meaningful_rate(
               p_userid        IN NUMBER,
               p_date          IN DATE,
               p_currency_code IN VARCHAR2,
               p_success_flag       OUT NOCOPY VARCHAR2,    -- Y/N
               p_conv_date          OUT NOCOPY DATE,
               p_conv_rate          OUT NOCOPY NUMBER,
               p_conv_currency_code IN OUT NOCOPY VARCHAR2);

   procedure get_meaningful_amount(
               p_userid        IN NUMBER,
               p_amount        IN NUMBER,
               p_date          IN DATE,
               p_currency_code IN VARCHAR2,
               p_success_flag       OUT NOCOPY VARCHAR2,    -- Y/N
               p_conv_amount        OUT NOCOPY NUMBER,
               p_conv_currency_code IN  OUT NOCOPY VARCHAR2);

   procedure get_meaningful_amount_emp(
               p_employee_id        IN NUMBER,
               p_amount        IN NUMBER,
               p_date          IN DATE,
               p_currency_code IN VARCHAR2,
               p_success_flag       OUT NOCOPY VARCHAR2,    -- Y/N
               p_conv_amount        OUT NOCOPY NUMBER,
               p_conv_currency_code OUT NOCOPY VARCHAR2);

   function get_meaningful_amount_msg(
               p_userid        IN NUMBER,
               p_amount        IN NUMBER,
               p_date          IN DATE,
               p_currency_code IN VARCHAR2,
               p_out_currency_code IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;

   function get_meaningful_amount_msg_emp(
               p_employee_id   IN NUMBER,
               p_amount        IN NUMBER,
               p_date          IN DATE,
               p_currency_code IN VARCHAR2,
               p_out_currency_code IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;

end ap_web_amount_util;

 

/
