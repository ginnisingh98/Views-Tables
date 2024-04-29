--------------------------------------------------------
--  DDL for Package Body RCV_GAPLESS_NUMBERING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_GAPLESS_NUMBERING" AS
/* $Header: RCVSBGNB.pls 120.1.12010000.2 2010/01/25 23:26:52 vthevark ship $ */

G_PKG_NAME CONSTANT VARCHAR2(32) := 'RCV_GAPLESS_NUMBERING';
g_asn_debug VARCHAR2(1) := asn_debug.is_debug_on; -- Bug 9152790

PROCEDURE generate_invoice_number (
   p_api_version            IN              NUMBER,
   p_org_id                 IN              NUMBER, -- BugFix 5192878
   p_vendor_site_id         IN              NUMBER, -- BugFix 5192878
-- p_buying_company_code    IN              VARCHAR2, -- BugFix 5192878
-- p_selling_company_code   IN              VARCHAR2, -- BugFix 5192878
   p_invoice_type           IN              VARCHAR2,
   x_invoice_num            OUT NOCOPY      VARCHAR2,
   x_return_status          OUT NOCOPY      VARCHAR2,
   x_msg_count              OUT NOCOPY      NUMBER,
   x_msg_data               OUT NOCOPY      VARCHAR2
)
IS
   l_api_version   CONSTANT NUMBER         := 1.0;
   l_api_name      CONSTANT VARCHAR2 (30)  := 'get_invoice_numbering_options';
   l_progress               VARCHAR2 (3);
   l_prefix                 VARCHAR2 (45);
   l_invoice_string         VARCHAR2 (45);
   l_next_sequence_number   NUMBER;
   l_rowid                  VARCHAR2 (250);

   -- Following varibales are declared for BugFix 5197828
   l_buying_company_identifier   VARCHAR2 (10);
   l_selling_company_identifier  VARCHAR2 (10);
   l_gapless_inv_num_flag_org    VARCHAR2 (1);
   l_gapless_inv_num_flag_sup    VARCHAR2 (1);
   l_return_status               VARCHAR2 (1);
   l_msg_data                    VARCHAR2 (2000);
   l_msg_count                   NUMBER;
   l_vendor_id                   NUMBER;
   l_organization_name		 HR_ORGANIZATION_UNITS.NAME%TYPE;
   l_organization_code           MTL_PARAMETERS.ORGANIZATION_CODE%TYPE;
   l_vendor_name                 PO_VENDORS.VENDOR_NAME%TYPE;
   l_vendor_site_code            PO_VENDOR_SITES_ALL.VENDOR_SITE_CODE%TYPE;
   l_org_code_name               VARCHAR2(300);
   -- End of code bugfix 5197828

   invoice_exception EXCEPTION;

   cursor get_next_sequence_number is
   SELECT        ROWID,
                 next_sequence_number
   FROM          rcv_gapless_invoice_numbers
   WHERE         (prefix = l_prefix OR (prefix IS NULL AND l_prefix IS NULL))
   AND           buying_company_code = l_buying_company_identifier
   AND           selling_company_code = l_selling_company_identifier
   AND           invoice_type = p_invoice_type
   FOR UPDATE OF next_sequence_number;

BEGIN

   IF (g_asn_debug = 'Y')
   THEN
       asn_debug.put_line ( 'Following are input parameters to rcv_gapless_numbering.generate_invoice_number package.');
       asn_debug.put_line ( 'p_org_id = ' || p_org_id );
       asn_debug.put_line ( 'p_vendor_site_id = ' || p_vendor_site_id );
       asn_debug.put_line ( 'p_invoice_type = ' || p_invoice_type );
   END IF;

   l_progress := '000';

   x_return_status := fnd_api.G_RET_STS_ERROR;

   l_progress := '010';

   -- Standard call to check for call compatibility
   IF NOT fnd_api.compatible_api_call (l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name
                                      ) THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

    -- BugFix 5197828
    BEGIN
        SELECT      DISTINCT pv.vendor_id ,
                    pv.vendor_name,
                    pvs.vendor_site_code
        INTO        l_vendor_id,
                    l_vendor_name,
                    l_vendor_site_code
        FROM        po_vendor_sites_all pvs,
                    po_vendors          pv
        WHERE       vendor_site_id = p_vendor_site_id
        AND         pvs.vendor_id = pv.vendor_id;

        IF (g_asn_debug = 'Y')
        THEN
                asn_debug.put_line ( 'Vendor_id = ' || l_vendor_id );
        END IF;

    EXCEPTION
            WHEN        OTHERS
            THEN
                 IF (g_asn_debug = 'Y')
                 THEN
                        asn_debug.put_line ( 'Error occured while selecting Vendor_id. Error message is =' || SQLERRM );
                 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    BEGIN
        SELECT      name
        INTO        l_organization_name
        FROM        hr_organization_units
        WHERE       organization_id = p_org_id;

        IF (g_asn_debug = 'Y')
        THEN
                asn_debug.put_line ( 'Orgnization name = ' || l_organization_name );
        END IF;
    EXCEPTION
            WHEN        OTHERS
            THEN
                 IF (g_asn_debug = 'Y')
                 THEN
                        asn_debug.put_line ( 'Error occured while selecting Organization Name. Error message is =' || SQLERRM );
                 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;


    BEGIN
        SELECT      organization_code
        INTO        l_organization_code
        FROM        mtl_parameters
        WHERE       organization_id = p_org_id;

        IF (g_asn_debug = 'Y')
        THEN
                asn_debug.put_line ( 'Orgnization Code = ' || l_organization_code );
        END IF;

        l_org_code_name := l_organization_code || ': ' || l_organization_name;

    EXCEPTION
            WHEN    NO_DATA_FOUND
            THEN
                    l_org_code_name := l_organization_name;
            WHEN    OTHERS
            THEN
                 IF (g_asn_debug = 'Y')
                 THEN
                        asn_debug.put_line ( 'Error occured while selecting Organization Code. Error message is =' || SQLERRM );
                 END IF;
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END;

    -- End of code BugFix 5197828

   -- Following code is moved from create_invoice_number procedure.
   -- x_gapless_inv_num_flag_org is Y and x_gapless_inv_num_flag_sup is Y
   -- then and then only we should generate the gapless numbers otherwise
   -- we will raise exception from this procedure.

   l_progress := '020';

   po_ap_integration_grp.get_invoice_numbering_options (1,
                                                        p_org_id,
                                                        l_return_status,
                                                        l_msg_data,
                                                        l_buying_company_identifier,
                                                        l_gapless_inv_num_flag_org
                                                       );

   IF (g_asn_debug = 'Y')
   THEN
      asn_debug.put_line ( 'po_ap_integration_grp.get_invoice_numbering_options returned with status ' || l_return_status);
      asn_debug.put_line ( 'l_buying_company_identifier = ' || l_buying_company_identifier );
      asn_debug.put_line ( 'l_gapless_inv_num_flag_org = ' || l_gapless_inv_num_flag_org);
   END IF;

   l_progress := '030';

   AP_PO_GAPLESS_SBI_PKG.site_uses_gapless_num (p_vendor_site_id,
                                                l_gapless_inv_num_flag_sup,
                                                l_selling_company_identifier
                                               );
   l_progress := '040';

   IF (g_asn_debug = 'Y')
   THEN
      asn_debug.put_line ( 'AP_PO_GAPLESS_SBI_PKG.site_uses_gapless_num returned with status ' || l_return_status);
      asn_debug.put_line ( 'l_gapless_inv_num_flag_sup = ' || l_gapless_inv_num_flag_sup );
      asn_debug.put_line ( 'l_selling_company_identifier = ' || l_selling_company_identifier);
   END IF;

     -- End of code BugFix 5197828

   IF ( l_gapless_inv_num_flag_org = 'N' and l_gapless_inv_num_flag_sup = 'N' )
   THEN
      x_return_status := fnd_api.G_RET_STS_SUCCESS;
      return;
   END IF;

   IF (l_buying_company_identifier is null) THEN

       IF (g_asn_debug = 'Y')
       THEN
            asn_debug.put_line ( 'Buying company identofier not defined loggeing error. for organization ' || l_org_code_name );
       END IF;

       FND_MESSAGE.set_name('PO','RCV_NO_BUYING_COMPANY_ID');
       FND_MESSAGE.SET_TOKEN('ORGCODENAME', l_org_code_name);     -- Bugfix 5197828

       RAISE invoice_exception;
   END IF;

   IF (l_selling_company_identifier is null) THEN
       IF (g_asn_debug = 'Y')
       THEN
            asn_debug.put_line ( 'Selling company identofier not defined loggeing error. for vendor '
                                  || l_vendor_name || ' and vendor site = ' || l_vendor_site_code );
       END IF;

       FND_MESSAGE.set_name('PO','RCV_NO_SELLING_COMPANY_ID');
       FND_MESSAGE.SET_TOKEN('VENDORNAME', l_vendor_name);      -- Bugfix 5197828
       FND_MESSAGE.SET_TOKEN('VENDORSITE', l_vendor_site_code); -- Bugfix 5197828

       RAISE invoice_exception;
   END IF;

   IF (p_invoice_type not in ('ERS','RTS','PPA')) THEN
     RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   l_progress := '020';

   IF (p_invoice_type = 'ERS') THEN
     fnd_profile.get ('ERS_PREFIX', l_prefix);
   END IF;

   IF (l_prefix = '') THEN
      l_prefix := NULL;
   END IF;

   l_progress := '030';

   open get_next_sequence_number;
   fetch get_next_sequence_number into l_rowid,l_next_sequence_number;
   close get_next_sequence_number;

   l_progress := '040';

   IF (l_next_sequence_number is null) THEN
     INSERT INTO rcv_gapless_invoice_numbers (prefix,
                                              buying_company_code,
                                              selling_company_code,
                                              invoice_type,
                                              next_sequence_number
                                             )
     VALUES (l_prefix,
             l_buying_company_identifier,  -- Bugfix 5197828
             l_selling_company_identifier, -- Bugfix 5197828
             p_invoice_type,
             1);

     l_progress := '050';

     open get_next_sequence_number;
     fetch get_next_sequence_number into l_rowid,l_next_sequence_number;
     close get_next_sequence_number;

     l_progress := '060';

   END IF;

   l_progress := '070';

   IF (l_prefix IS NULL) THEN
      l_invoice_string := '';
   ELSE
      l_invoice_string := l_prefix || '-';
   END IF;

   l_invoice_string :=
          l_invoice_string
       || l_buying_company_identifier  -- Bugfix 5197828
       || '-'
       || l_selling_company_identifier -- Bugfix 5197828
       || '-'
       || p_invoice_type
       || '-';

   WHILE (ap_po_gapless_sbi_pkg.this_is_dup_inv_num (   l_invoice_string
                                                     || TO_CHAR (l_next_sequence_number
                                                                ),
                                                     l_selling_company_identifier  -- Bugfix 5197828
                                                    )
         )
   LOOP
      l_next_sequence_number := l_next_sequence_number + 1;
   END LOOP;

   l_progress := '080';

   IF (length(l_invoice_string || l_next_sequence_number)>45) THEN
      FND_MESSAGE.set_name('PO','RCV_INVOICE_NUM_TOO_LONG');
      RAISE invoice_exception;
   END IF;

   x_invoice_num := l_invoice_string || l_next_sequence_number;
   l_next_sequence_number := l_next_sequence_number + 1;

   UPDATE rcv_gapless_invoice_numbers
      SET next_sequence_number = l_next_sequence_number
    WHERE ROWID = l_rowid;

   l_progress := '100';

   x_return_status := fnd_api.G_RET_STS_SUCCESS;
   FND_MSG_PUB.get(
      p_msg_index     => FND_MSG_PUB.G_LAST,
      p_encoded       => 'F',
      p_msg_index_out => x_msg_count,
      p_data          => x_msg_data );

EXCEPTION
   WHEN invoice_exception THEN
      x_return_status := fnd_api.g_ret_sts_error;
      FND_MSG_PUB.add;
      FND_MSG_PUB.get(
         p_msg_index     => FND_MSG_PUB.G_LAST,
         p_encoded       => 'F',
         p_msg_index_out => x_msg_count,
         p_data          => x_msg_data );
   WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MESSAGE.set_name('PO','RCV_SYSTEM_ERROR');
      FND_MSG_PUB.add;
      FND_MSG_PUB.get(
         p_msg_index     => FND_MSG_PUB.G_LAST,
         p_encoded       => 'F',
         p_msg_index_out => x_msg_count,
         p_data          => x_msg_data );
   WHEN OTHERS THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      FND_MESSAGE.set_name('PO','RCV_SYSTEM_ERROR');
      FND_MSG_PUB.add;

      IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg (p_pkg_name            => g_pkg_name,
                                  p_procedure_name      => l_api_name,
                                  p_error_text          =>    SUBSTRB (SQLERRM,
                                                                       1,
                                                                       200
                                                                      )
                                                           || ' : '
                                                           || l_progress
                                 );
      END IF;

      FND_MSG_PUB.get(
         p_msg_index     => FND_MSG_PUB.G_LAST,
         p_encoded       => 'F',
         p_msg_index_out => x_msg_count,
         p_data          => x_msg_data );

      IF get_next_sequence_number%ISOPEN THEN
         CLOSE get_next_sequence_number;
      END IF;
END generate_invoice_number;


END RCV_GAPLESS_NUMBERING;

/
