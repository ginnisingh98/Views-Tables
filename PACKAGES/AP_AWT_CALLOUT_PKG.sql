--------------------------------------------------------
--  DDL for Package AP_AWT_CALLOUT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_AWT_CALLOUT_PKG" AUTHID CURRENT_USER AS
 /* $Header: apibyhks.pls 120.2 2005/08/26 00:52:27 rguerrer ship $ */

Procedure zx_paymentsAdjustHook(
  p_api_version    IN NUMBER,
  p_init_msg_list  IN VARCHAR2,
  p_commit         IN VARCHAR2,
  x_return_status  OUT NOCOPY VARCHAR2,
  x_msg_count      OUT NOCOPY NUMBER,
  x_msg_data       OUT NOCOPY VARCHAR2);

PROCEDURE zx_witholdingCertificatesHook
 ( p_payment_instruction_ID IN NUMBER,
   p_calling_module         IN VARCHAR2,
   p_api_version            IN NUMBER,
   p_init_msg_list          IN VARCHAR2 ,
   p_commit                 IN VARCHAR2,
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2);

END AP_AWT_CALLOUT_PKG;

 

/
