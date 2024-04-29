--------------------------------------------------------
--  DDL for Package Body OE_UPG_INSTALL_DETAILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_UPG_INSTALL_DETAILS" as
/* $Header: OEXIUIDB.pls 120.0 2005/06/01 01:55:23 appldev noship $ */

Procedure Upgrade_Insert_Errors
   (
      L_header_id             IN  Varchar2,
      L_comments              IN  varchar2
   )
   is

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
   Begin
       insert into oe_upgrade_errors
       (
           header_id,
           comments,
           creation_date
       )
       values
       (
           l_header_id,
           substr(l_comments,1,240),
           sysdate
       );

End Upgrade_Insert_Errors;



PROCEDURE upgrade_install_details
(
 p_slab IN NUMBER DEFAULT NULL
 ) IS

    TYPE install_lines_upg_cursor IS ref CURSOR;

    install_lines install_lines_upg_cursor;

    -- This dynamic statement is included because so that this script
    -- compatible with both 11.5.1.A patch driver (which does not
    -- pass the p_slab argument) and 11.5.2 patch driver
    -- which uses parallel workers to execute this script.
    -- The between clause will be appended only for 11.5.2 when the
    -- slab parameter is being passed.

    l_install_lines_stmt VARCHAR2(2000) :=
      'SELECT sld.line_service_detail_id, sld.line_id' ||
      ' FROM so_line_service_details sld,' ||
      '      oe_order_lines_all ol' ||
      ' WHERE ol.line_id = sld.line_id' ||
      ' AND NOT exists' ||
      ' (SELECT 1' ||
      '  FROM cs_line_inst_details csd' ||
      '  WHERE csd.line_inst_detail_id = sld.line_service_detail_id)';

    l_between_clause VARCHAR2(240) :=
      ' AND sld.line_service_detail_id BETWEEN :b_start_id AND :b_end_id';

    l_start_id                NUMBER := NULL;
    l_end_id                  NUMBER := NULL;

    l_parent_line_id          NUMBER;
    l_header_id               NUMBER := NULL;
    l_install_detail_line_id  NUMBER;
    l_new_line_inst_detail_id NUMBER;
    l_return_status           VARCHAR2(1);
    l_msg_count               NUMBER := 0;
    l_msg_data                VARCHAR2(2000);
    l_msg_index               NUMBER;
    l_object_version_number   NUMBER;
    l_count                   NUMBER := 0;

    l_line_inst_dtl_rec       CS_InstalledBase_PUB.Line_Inst_Dtl_Rec_Type;
    l_old_line_inst_dtl_rec   CS_Inst_Detail_PUB.Line_Inst_Dtl_Rec_Type;
    l_install_details_rec     CS_InstalledBase_PUB.Line_Inst_Dtl_Rec_Type;
    l_old_line_inst_dtl_desc_flex CS_InstalledBase_PUB.DFF_Rec_Type;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF p_slab IS NOT NULL THEN

      l_install_lines_stmt := l_install_lines_stmt || l_between_clause;

      BEGIN

	 SELECT  start_header_id, end_header_id
	   INTO  l_start_id, l_end_id
	   FROM  oe_upgrade_distribution
	   WHERE slab = p_slab
	   AND   line_type = 'I';

      EXCEPTION
	 WHEN no_data_found THEN

	    oe_upg_install_details.upgrade_insert_errors
	      (
	       l_header_id => 0,
	       l_comments => 'FYI Only: Parallel process of '
	       || 'Installation Details. Marking not used for slab: '
	       || To_char(p_slab)
	       );
	    COMMIT;

	    -- Return if no data found in oe_upgrade_distribution

	    RETURN;
      END;
   END IF;


   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING INSTALLATION DETAILS' ) ;
   END IF;

   -- Get the parent line which has installation details

   IF p_slab IS NULL THEN
      OPEN install_lines FOR l_install_lines_stmt;
    ELSE
      OPEN install_lines FOR l_install_lines_stmt using l_start_id, l_end_id;
   END IF;

  LOOP

     FETCH INSTALL_LINES INTO
	l_install_detail_line_id, l_parent_line_id;
     EXIT WHEN INSTALL_LINES%NOTFOUND;

     /* Check for the parent line if there are multiple installation details */

     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'PARENT LINE ID : ' || L_PARENT_LINE_ID ) ;
     END IF;

	/* Get the installation details record from SO_LINES_SERVICE_DETAILS */
     Get_Line_Inst_Details
       (
	p_line_inst_details_id =>l_install_detail_line_id,
	x_line_inst_dtl_rec => l_old_line_inst_dtl_rec,
	x_line_inst_dtl_desc_flex => l_old_line_inst_dtl_desc_flex
	);

     l_count := l_count + 1;

     BEGIN -- calling crm api

	CS_Inst_Detail_PUB.create_installation_details
	  (
	   p_api_version    => 1.0
	   ,p_init_msg_list  => FND_API.G_TRUE
	   ,x_return_status  => l_return_status
	   ,x_msg_count      => l_msg_count
	   ,x_msg_data       => l_msg_data
	   ,p_line_inst_dtl_rec => l_old_line_inst_dtl_rec
	   ,p_line_inst_dtl_desc_flex => l_old_line_inst_dtl_desc_flex
	   ,p_upgrade    => FND_API.G_TRUE
	   ,x_object_version_number => l_object_version_number
	   ,x_line_inst_detail_id => l_new_line_inst_detail_id
	   );

     EXCEPTION
	WHEN fnd_api.g_exc_error THEN

	   --
	   -- this is to work around a bug 1349874 filed against CRM
	   --

	   l_return_status := FND_API.g_ret_sts_error;
	   l_msg_count := 1;
	   l_msg_data := 'NO_DATA_FOUND Raised from CS_INST_DETAIL_PUB';

	WHEN OTHERS THEN
	   RAISE;
     END; -- calling crm api

     IF l_count > 500 THEN
	commit;
	l_count := 0;
     END IF;

     IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'CREATE INSTALLATION DETAILS - UNEXPECTED ERROR' ) ;
	END IF;
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'EXITING INSTALLATION DETAILS API' ) ;
	END IF;
      ELSIF l_return_status = FND_API.G_RET_STS_ERROR THEN
	IF l_debug_level  > 0 THEN
	    oe_debug_pub.add(  'INSTALLATION DETAILS - ERROR' ) ;
	END IF;
     END IF;

     IF NOT (l_return_status = FND_API.G_RET_STS_SUCCESS) then

        BEGIN
	   select header_id into l_header_id
	     from so_lines_all where line_id = l_parent_line_id;
	EXCEPTION

	   -- This exception is coded to handle a data corruption issue
	   -- with Oracle IT where installation details existed but
	   -- line_id's did not.

	   WHEN NO_DATA_FOUND THEN

	      l_header_id := NULL;
              oe_upg_install_details.upgrade_insert_errors
		(
		 L_header_id => l_header_id,
		 L_comments =>
		 'Upgrade of Installation details failed for detail:'
		 || to_char(l_install_detail_line_id)||' with error: '
                 || 'Line ID: ' || l_parent_line_id || ' does not exist'
		 );
        END;

	l_msg_index := 1;
	while l_msg_count > 0 loop
	   l_msg_data := fnd_msg_pub.get(l_msg_index, FND_API.G_FALSE);
	   oe_upg_install_details.upgrade_insert_errors
	     (
	      L_header_id => l_header_id,
	      L_comments =>
	      'Upgrade of Installation details failed for detail :'
	      ||to_char(l_install_detail_line_id)||' with error: '
	      || l_msg_data
	      );

	   l_msg_index := l_msg_index + 1;
	   l_msg_count := l_msg_count - 1;
	end loop;

      END IF;

  END LOOP;
  CLOSE install_lines;
Exception
   when others THEN

--      dbms_output.put_line('Line_id is: ' || l_old_line_inst_dtl_rec.order_line_id
--			   || ' line_service_detail_id is: ' || l_old_line_inst_dtl_rec.line_inst_detail_id);

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END Upgrade_install_details;


PROCEDURE Get_Line_Inst_Details
( p_line_inst_details_id       IN   NUMBER,
x_line_inst_dtl_rec OUT NOCOPY CS_Inst_Detail_PUB.Line_Inst_Dtl_Rec_Type,

x_line_inst_dtl_desc_flex OUT NOCOPY CS_InstalledBase_PUB.DFF_Rec_Type

)
IS

l_line_inst_dtl_rec           CS_Inst_Detail_PUB.Line_Inst_Dtl_Rec_Type;
l_line_inst_dtl_desc_flex     CS_InstalledBase_PUB.DFF_Rec_Type;
l_party_site_id               NUMBER := NULL;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN


   SELECT
	lsd.line_service_detail_id,
	lsd.line_id,
	lsd.source_line_service_detail_id,
	lsd.transaction_type_id,
	lsd.system_id,
	--lsd.system_type_code,
	lsd.customer_product_id,
	lsd.customer_product_type_code,
	lsd.customer_product_quantity,
	lsd.installation_site_use_id,
	lsd.installed_cp_return_by_date,
	lsd.new_cp_return_by_date,
	--lsd.technical_contact_id,
	--lsd.service_admin_contact_id,
	lsd.context,
	lsd.attribute1,
	lsd.attribute2,
	lsd.attribute3,
	lsd.attribute4,
	lsd.attribute5,
	lsd.attribute6,
	lsd.attribute7,
	lsd.attribute8,
	lsd.attribute9,
	lsd.attribute10,
	lsd.attribute11,
	lsd.attribute12,
	lsd.attribute13,
	lsd.attribute14,
	lsd.attribute15,
        cas.party_site_id
     INTO
	l_line_inst_dtl_rec.line_inst_detail_id,
	l_line_inst_dtl_rec.order_line_id,
	l_line_inst_dtl_rec.source_line_inst_detail_id,
	l_line_inst_dtl_rec.transaction_type_id,
	l_line_inst_dtl_rec.system_id,
	--l_line_inst_dtl_rec.system_type_code,
	l_line_inst_dtl_rec.customer_product_id,
	l_line_inst_dtl_rec.type_code,
	l_line_inst_dtl_rec.quantity,
	l_line_inst_dtl_rec.installed_at_party_site_id,
	l_line_inst_dtl_rec.installed_cp_return_by_date,
	l_line_inst_dtl_rec.new_cp_return_by_date,
	l_line_inst_dtl_desc_flex.context,
	l_line_inst_dtl_desc_flex.attribute1,
	l_line_inst_dtl_desc_flex.attribute2,
	l_line_inst_dtl_desc_flex.attribute3,
	l_line_inst_dtl_desc_flex.attribute4,
	l_line_inst_dtl_desc_flex.attribute5,
	l_line_inst_dtl_desc_flex.attribute6,
	l_line_inst_dtl_desc_flex.attribute7,
	l_line_inst_dtl_desc_flex.attribute8,
	l_line_inst_dtl_desc_flex.attribute9,
	l_line_inst_dtl_desc_flex.attribute10,
	l_line_inst_dtl_desc_flex.attribute11,
	l_line_inst_dtl_desc_flex.attribute12,
	l_line_inst_dtl_desc_flex.attribute13,
	l_line_inst_dtl_desc_flex.attribute14,
	l_line_inst_dtl_desc_flex.attribute15,
        l_party_site_id
	FROM
           HZ_CUST_ACCT_SITES_ALL CAS,
           HZ_CUST_SITE_USES_ALL CSU,
	   SO_LINE_SERVICE_DETAILS LSD
     WHERE
           csu.cust_acct_site_id = cas.cust_acct_site_id (+)
     AND   lsd.installation_site_use_id = csu.site_use_id (+)
     AND   lsd.line_service_detail_id = p_line_inst_details_id;

  x_line_inst_dtl_rec     := l_line_inst_dtl_rec;

  /* Assign the missing values */

  x_line_inst_dtl_desc_flex     := l_line_inst_dtl_desc_flex;

  l_line_inst_dtl_rec.installed_at_party_site_id := l_party_site_id;  --  1949721, 2023975

EXCEPTION
   WHEN OTHERS THEN
	    IF l_debug_level  > 0 THEN
	        oe_debug_pub.add(  'ERROR IN GET_LINE_INST_DETAILS' ) ;
	    END IF;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

End Get_Line_Inst_Details;

END oe_upg_install_details;

/
