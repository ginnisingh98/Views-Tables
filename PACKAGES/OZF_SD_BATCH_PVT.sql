--------------------------------------------------------
--  DDL for Package OZF_SD_BATCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_SD_BATCH_PVT" AUTHID CURRENT_USER as
  /* $Header: ozfvsdbs.pls 120.15.12010000.13 2009/12/23 11:07:22 annsrini ship $ */

  -- Start of Comments
  -- Package name     : OZF_SD_BATCH_PVT
  -- Purpose          :
  -- History          :
  --  26-SEP-2008  -   ANNSRINI -  Modified p_start_date and p_end_date to varchar instead of DATE in create_batch_main
  --  19-JUN-2009  -   ANNSRINI -  3 APIs added - PROCESS_SD_PENDING_CLM_BATCHES, PROCESS_SUPPLIER_SITES and INVOKE_CLAIM
  --  20-JUL-2009  -   ANNSRINI -  Adjustment related changes
  --  07-DEC-2009  -   ANNSRINI -  changes w.r.t multicurrency
  -- NOTE             :
  -- End of Comments

  --G_PKG_NAME  CONSTANT VARCHAR2(30) := 'OZF_SD_BATCH_PVT';
  --G_FILE_NAME   CONSTANT VARCHAR2(12)   := 'ozfvsdbs.pls';

  -- Author  : MBHATT
  -- Created : 11/16/2007 2:39:16 PM
  -- Purpose :
  -- Public function and procedure declarations
  -- Private type declarations

  PROCEDURE create_batch_main(errbuf             OUT nocopy VARCHAR2,
                              retcode            OUT nocopy NUMBER,
                              p_org_id           IN NUMBER,
                              p_supplier_id      IN NUMBER,
                              p_supplier_site_id IN NUMBER,
                              --p_category_id IN NUMBER,
                              p_fund_id    IN NUMBER,
                              p_request_id IN NUMBER,
                              p_product_id IN NUMBER,
                              p_start_date IN VARCHAR2,
                              p_end_date   IN VARCHAR2,
                              p_period     IN VARCHAR2,
			     p_attribute1 IN VARCHAR2 := NULL,
                             p_attribute2 IN VARCHAR2 := NULL,
                             p_attribute3 IN VARCHAR2 := NULL,
                             p_attribute4 IN VARCHAR2 := NULL,
                             p_attribute5 IN VARCHAR2 := NULL,
                             p_attribute6 IN VARCHAR2 := NULL,
                             p_attribute7 IN VARCHAR2 := NULL,
                             p_attribute8 IN VARCHAR2 := NULL,
                             p_attribute9 IN VARCHAR2 := NULL,
                             p_attribute10 IN VARCHAR2 := NULL,
                             p_attribute11 IN VARCHAR2 := NULL,
                             p_attribute12 IN VARCHAR2 := NULL,
			     p_attribute13 IN VARCHAR2 := NULL,
                             p_attribute14 IN VARCHAR2 := NULL,
			     p_attribute15 IN VARCHAR2 := NULL);

  PROCEDURE create_batch_sub(p_org_id           IN NUMBER,
                             p_supplier_id      IN NUMBER,
                             p_supplier_site_id IN NUMBER,
                             --p_category_id IN NUMBER,
                             p_product_id IN NUMBER,
                             p_request_id IN NUMBER,
                             p_fund_id    IN NUMBER,
                             p_start_date IN DATE,
                             p_end_date   IN DATE,
                             p_period     IN VARCHAR2,
                             p_commit              IN  VARCHAR2  := FND_API.g_false,
			     p_attribute1 IN VARCHAR2 := NULL,
			     p_attribute2 IN VARCHAR2 := NULL,
                             p_attribute3 IN VARCHAR2 := NULL,
                             p_attribute4 IN VARCHAR2 := NULL,
                             p_attribute5 IN VARCHAR2 := NULL,
                             p_attribute6 IN VARCHAR2 := NULL,
                             p_attribute7 IN VARCHAR2 := NULL,
                             p_attribute8 IN VARCHAR2 := NULL,
                             p_attribute9 IN VARCHAR2 := NULL,
                             p_attribute10 IN VARCHAR2 := NULL,
                             p_attribute11 IN VARCHAR2 := NULL,
                             p_attribute12 IN VARCHAR2 := NULL,
			     p_attribute13 IN VARCHAR2 := NULL,
                             p_attribute14 IN VARCHAR2 := NULL,
			     p_attribute15 IN VARCHAR2 := NULL);

  Procedure CREATE_BATCH(p_empty_batch      OUT NOCOPY VARCHAR2,
                         p_supplier_id      IN NUMBER,
                         p_supplier_site_id IN NUMBER,
                         p_org_id           IN NUMBER,
                         --p_category_id IN NUMBER,
                         p_product_id    IN NUMBER,
                         p_request_id    IN NUMBER,
                         p_fund_id       IN NUMBER,
                         p_start_date    IN DATE,
                         p_end_date      IN DATE,
                         p_period        IN VARCHAR2,
                         p_currency_code IN VARCHAR2,
			 p_attribute1 IN VARCHAR2 := NULL,
			 p_attribute2 IN VARCHAR2 := NULL,
                         p_attribute3 IN VARCHAR2 := NULL,
                         p_attribute4 IN VARCHAR2 := NULL,
                         p_attribute5 IN VARCHAR2 := NULL,
                         p_attribute6 IN VARCHAR2 := NULL,
                         p_attribute7 IN VARCHAR2 := NULL,
                         p_attribute8 IN VARCHAR2 := NULL,
                         p_attribute9 IN VARCHAR2 := NULL,
                         p_attribute10 IN VARCHAR2 := NULL,
                         p_attribute11 IN VARCHAR2 := NULL,
                         p_attribute12 IN VARCHAR2 := NULL,
			 p_attribute13 IN VARCHAR2 := NULL,
                         p_attribute14 IN VARCHAR2 := NULL,
			 p_attribute15 IN VARCHAR2 := NULL);

  Procedure CREATE_BATCH_HEADER(p_supplier_id          IN NUMBER,
                                p_supplier_site_id     IN NUMBER,
                                p_org_id               IN NUMBER,
                                p_batch_threshold         NUMBER,
                                p_line_threshold          NUMBER,
                                p_batch_currency          VARCHAR2,
				p_batch_new            IN VARCHAR2,
				p_batch_status         IN VARCHAR2,
				p_claim_number         IN VARCHAR2,
				p_claim_minor_version  IN NUMBER,
				p_parent_batch_id      IN NUMBER,
                                p_batch_id             OUT nocopy NUMBER);

  Procedure CREATE_BATCH_LINES(p_batch_id          IN NUMBER,
                               p_supplier_id       IN NUMBER,
                               p_supplier_site_id  IN NUMBER,
                               p_org_id            IN NUMBER,
                               p_thresh_line_limit IN NUMBER,
                               p_batch_currency    IN VARCHAR2,
                               --p_category_id IN NUMBER,
                               p_product_id  IN NUMBER,
                               p_request_id  IN NUMBER,
                               p_fund_id     IN NUMBER,
                               p_start_date  IN DATE,
                               p_end_date    IN DATE,
                               p_period      IN VARCHAR2,
                               p_empty_batch OUT NOCOPY VARCHAR2,
			       p_attribute1 IN VARCHAR2 := NULL,
			       p_attribute2 IN VARCHAR2 := NULL,
                               p_attribute3 IN VARCHAR2 := NULL,
                               p_attribute4 IN VARCHAR2 := NULL,
                               p_attribute5 IN VARCHAR2 := NULL,
                               p_attribute6 IN VARCHAR2 := NULL,
                               p_attribute7 IN VARCHAR2 := NULL,
                               p_attribute8 IN VARCHAR2 := NULL,
                               p_attribute9 IN VARCHAR2 := NULL,
                               p_attribute10 IN VARCHAR2 := NULL,
                               p_attribute11 IN VARCHAR2 := NULL,
                               p_attribute12 IN VARCHAR2 := NULL,
			       p_attribute13 IN VARCHAR2 := NULL,
                               p_attribute14 IN VARCHAR2 := NULL,
			       p_attribute15 IN VARCHAR2 := NULL);

  Procedure UPDATE_AMOUNTS(p_batch_id        IN NUMBER,
                           p_batch_threshold IN NUMBER);


  FUNCTION GET_BATCH_CURRENCY_AMOUNT(p_func_currency  VARCHAR2,
                                     p_batch_currency VARCHAR2,
				     p_acctd_amount   NUMBER,
				     p_conv_type      VARCHAR2,
				     p_conv_rate      NUMBER,
				     p_date           DATE) RETURN NUMBER;

  FUNCTION GET_VENDOR_ITEM_ID(p_product_id number, p_supplier_site_id number)
    return varchar2;

  FUNCTION CONV_DISC_TO_OFFER_CURR_AMOUNT(p_offer_currency VARCHAR2,
                                     p_discount_val_currency VARCHAR2,
                                     p_discount_val       number,
				     p_date date) RETURN number;

 procedure INVOKE_BATCH_AUTO_CLAIM(errbuf           OUT nocopy VARCHAR2,
                                    retcode          OUT nocopy NUMBER,
                                    p_batch_id       number,
                                    p_vendor_id      number,
                                    p_vendor_site_id number
                                    );

FUNCTION CURR_ROUND_EXT_PREC( p_amount IN NUMBER,
                              p_currency_code IN VARCHAR2
                            ) return number;

PROCEDURE PROCESS_SD_PENDING_CLM_BATCHES(errbuf           OUT nocopy VARCHAR2,
				           retcode          OUT nocopy NUMBER,
                                           p_org_id         NUMBER,
				           p_vendor_id      NUMBER,
                                           p_vendor_site_id NUMBER,
				           p_batch_id       NUMBER);

PROCEDURE PROCESS_SUPPLIER_SITES(p_org_id         IN NUMBER,
                                 p_vendor_id      IN NUMBER,
		                 p_vendor_site_id IN NUMBER,
		                 p_batch_id       IN NUMBER);

PROCEDURE INVOKE_CLAIM(p_org_id         IN NUMBER,
                       p_vendor_id      IN NUMBER,
		       p_vendor_site_id IN NUMBER,
		       p_batch_id       IN NUMBER);

END OZF_SD_BATCH_PVT;


/
