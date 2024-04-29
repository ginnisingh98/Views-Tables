--------------------------------------------------------
--  DDL for Package Body PON_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_VENDORMERGE_GRP" as
-- $Header: PONVDMGB.pls 120.19 2006/10/04 10:03:20 ppaulsam noship $

-- Read the profile option that enables/disables the debug log
-- store the profile value for logging in a global constant variable

 g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
 g_pkg_name CONSTANT VARCHAR2(30) := 'PON_VENDORMERGE_GRP';
 g_api_name	 CONSTANT VARCHAR2(30) := 'MERGE_VENDOR';

	  /*	      FORWARD Declaration Start 	       */

 FUNCTION GET_ACTIVE_SITE_COUNT(p_dup_vendor_id IN NUMBER,
			 p_dup_vendor_site_id  IN NUMBER) RETURN NUMBER;


PROCEDURE GET_MERGE_TO_VENDOR_INFO(p_vendor_id IN NUMBER,
				     p_vendor_site_id IN NUMBER,
				     x_return_status IN OUT NOCOPY VARCHAR2 ,
				     x_msg_count IN OUT NOCOPY NUMBER,
				     x_msg_data IN OUT NOCOPY VARCHAR2,
				     x_trading_partner_name OUT NOCOPY VARCHAR2,
				     x_vendor_site_code OUT NOCOPY VARCHAR2);

-- This will be called when two sites are being merged for same vendors
PROCEDURE MERGE_SAME_VENDOR_DIFF_SITES(p_vendor_id		      IN   NUMBER,
				      p_vendor_site_id		      IN   NUMBER,
				      p_vendor_site_code	      IN   VARCHAR2,
				      p_dup_vendor_id		      IN   NUMBER,
				      p_dup_vendor_site_id	      IN   NUMBER,
				      x_return_status		      IN   OUT NOCOPY  VARCHAR2,
				      x_msg_count		      IN   OUT NOCOPY  NUMBER,
				      x_msg_data		      IN   OUT NOCOPY  VARCHAR2);

-- This will be called when two sites are being merged for different vendors
-- Here merge to supplier site can be null, in that case copy operation will be
-- perfomed and site will be created with same name as of merge from supplier site.

 PROCEDURE MERGE_DIFF_VENDOR_AND_SITE( p_trading_partner_id		 IN   NUMBER,
					p_dup_trading_partner_id	IN   NUMBER,
					p_vendor_id			IN   NUMBER,
					p_vendor_site_id		IN   NUMBER,
					p_vendor_site_code		IN   VARCHAR2,
					p_dup_vendor_id 		IN   NUMBER,
					p_dup_vendor_site_id		IN   NUMBER,
					p_trading_partner_name		IN   VARCHAR2,
					x_return_status 		IN  OUT NOCOPY	VARCHAR2,
					x_msg_count			IN OUT NOCOPY  NUMBER,
					x_msg_data			IN OUT NOCOPY	VARCHAR2);

-- This will be called when two sites are being merged for different vendors
-- and the site being mearged is the last site.
-- Here the supplier being mearged will be marked as inactive.

 PROCEDURE MERGE_DIFF_VENDOR_LAST_SITE(p_trading_partner_id		 IN   NUMBER,
					p_dup_trading_partner_id	IN   NUMBER,
					p_vendor_id			IN   NUMBER,
					p_vendor_site_id		IN   NUMBER,
					p_vendor_site_code		IN   VARCHAR2,
					p_dup_vendor_id 		IN   NUMBER,
					p_dup_vendor_site_id		IN   NUMBER,
					p_trading_partner_name		IN   VARCHAR2,
					x_return_status 		IN  OUT NOCOPY	VARCHAR2,
					x_msg_count			IN OUT NOCOPY  NUMBER,
					x_msg_data			IN OUT NOCOPY	VARCHAR2);

 -- This is called to insert a record in pon_supplier_activities
 -- when two different vendor / vendor sites are merged.

 PROCEDURE UPDATE_SUPPLIER_ACTIVITY(p_dup_trading_partner_id IN   NUMBER,
					             x_return_status  IN  OUT NOCOPY	VARCHAR2,
					             x_msg_count	  IN OUT NOCOPY  NUMBER,
					             x_msg_data	      IN OUT NOCOPY	VARCHAR2);

	  /*	      FORWARD Declaration End		     */


  PROCEDURE MERGE_VENDOR (p_api_version 	   IN		 NUMBER,
			  p_vendor_id		       IN	     NUMBER,
			  p_dup_vendor_id      IN	     NUMBER,
			  p_vendor_site_id     IN	     NUMBER,
			  p_dup_vendor_site_id IN	     NUMBER,
			  p_party_id		       IN	     NUMBER,
			  P_dup_party_id       IN	     NUMBER,
			  p_party_site_id      IN	     NUMBER,
			  p_dup_party_site_id  IN	     NUMBER,
			  p_init_msg_list      IN	     VARCHAR2 default FND_API.G_FALSE,
			  p_commit		   IN		     VARCHAR2 default FND_API.G_FALSE,
			  p_validation_level   IN	     NUMBER   default FND_API.G_VALID_LEVEL_FULL,
			  p_return_status      OUT  NOCOPY   VARCHAR2,
			  p_msg_count		       OUT  NOCOPY   NUMBER,
			  p_msg_data		       OUT  NOCOPY   VARCHAR2)
  IS

  l_api_version   CONSTANT NUMBER	:= 1.0;
  l_procedure_name VARCHAR2(20) := 'MERGE_VENDOR';

  l_progress			      NUMBER;
  x_trading_partner_id		      pon_bid_headers.trading_partner_id%type;
  x_trading_partner_name	      pon_bid_headers.trading_partner_name%type;
  x_vendor_site_code		      po_vendor_sites_all.vendor_site_code%type;
  l_num_active_sites NUMBER;

  BEGIN --{

  l_progress := 100;

   IF (g_fnd_debug = 'Y') THEN --{
     IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
	   FND_LOG.string (log_level => FND_LOG.level_procedure,
			   module => g_pkg_name || l_procedure_name,
			   message  =>	  ' l_progress		 '  || l_progress
				       || ' p_api_version	 '  || p_api_version
				       || ' p_init_msg_list	 '  || p_init_msg_list
				       || ' p_commit		 '  || p_commit
				       || ' p_validation_level	 '  || p_validation_level
				       || ' p_return_status	 '  || p_return_status
				       || ' p_msg_count 	 '  || p_msg_count
				       || ' p_msg_data		 '  || p_msg_data
				       || ' p_vendor_id 	 '  || p_vendor_id
				       || ' p_dup_vendor_id	 '  || p_dup_vendor_id
				       || ' p_vendor_site_id	 '  || p_vendor_site_id
				       || ' p_dup_vendor_site_id '  || p_dup_vendor_site_id
				       || ' p_party_id		 '  || p_party_id
				       || ' P_dup_party_id	 '  || P_dup_party_id
				       || ' p_party_site_id	 '  || p_party_site_id
				       || ' p_dup_party_site_id  '  || p_dup_party_site_id   );
     END IF;
   END IF; --}

   fnd_file.put_line (fnd_file.log, l_progress|| 'Start : PON_VENDORMERGE_GRP.MERGE_VENDOR ');
   fnd_file.put_line (fnd_file.log, l_progress|| ' p_vendor_id      '  || p_vendor_id);
   fnd_file.put_line (fnd_file.log, l_progress|| ' p_dup_vendor_id  '  || p_dup_vendor_id);
   fnd_file.put_line (fnd_file.log, l_progress|| ' p_vendor_site_id     '  || p_vendor_site_id);
   fnd_file.put_line (fnd_file.log, l_progress|| ' p_dup_vendor_site_id '  || p_dup_vendor_site_id);
   fnd_file.put_line (fnd_file.log, l_progress|| ' p_party_id       '  || p_party_id);
   fnd_file.put_line (fnd_file.log, l_progress|| ' P_dup_party_id   '  || P_dup_party_id);
   fnd_file.put_line (fnd_file.log, l_progress|| ' p_party_site_id  '  || p_party_site_id);
   fnd_file.put_line (fnd_file.log, l_progress|| ' p_dup_party_site_id  '  || p_dup_party_site_id   );

     -- Standard call to check for call compatibility

     IF (NOT FND_API.Compatible_API_Call(l_api_version,p_api_version,g_api_name,g_pkg_name)) THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     l_progress := 101;
     fnd_file.put_line (fnd_file.log, l_progress|| 'Done compatibility Check ....');

     -- Check p_init_msg_list
     IF FND_API.to_Boolean(p_init_msg_list) THEN
	    FND_MSG_PUB.initialize;
     END IF;

     l_progress := 102;
     fnd_file.put_line (fnd_file.log, l_progress|| 'Done FND_MSG_PUB.initialize ');

     -- Initialize API return status to success
     p_return_status := FND_API.G_RET_STS_SUCCESS;


      --  Raise an Exception if l_party_id = null or l_party_id =  -1

     IF ( p_party_id = null OR p_party_id =  -1) THEN --{
		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF; --}


     l_progress := 103;
     fnd_file.put_line (fnd_file.log, l_progress|| 'Done party_id check....');

     --  Raise an Exception if l_dup_party_id = null or  l_dup_party_id =  -1

     IF ( p_dup_party_id = null OR  p_dup_party_id = null -1) THEN  --{
		p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF; --}

	 l_progress := 104;
     fnd_file.put_line (fnd_file.log, l_progress|| 'Done dup_party_id check....');

     /*
	 We have Following scenario to deal with Merge routine.

       |===============================================================================================|
       |        |From supplier | From suppl site| Copy | To supplier | To supplier site |              |
       |        |==============|================|======|=============|==================|              |
       |        |p_dup_vendor  | p_dup_site_id  |      | p_vendor_id | p_vendor_site_id |              |
       |========|==============|================|======|=============|==================|==============|
       |========|==============|================|======|=============|==================|==============|
       | Case 1 |Supp A	       | Site 1		    |      | Supp A	     | Site 2	        |  Allowed     |
       |========|==============|================|======|=============|==================|==============|
       | Case 2 |Supp A 	   | Site 1		    |      | Supp B	     | Site 2	        |  Allowed     |
       |========|==============|================|======|=============|==================|==============|
       |        |Supp A	       | Null		    |      | Supp B	     | Null	            |  Not Allowed |
       |        |==============|================|======|=============|==================|==============|
       |        |Supp A	       | Null			|      | Supp B	     | Site 2	        |  Not Allowed |
       |        |==============|================|======|=============|==================|==============|
       |        |Supp A	       | Site 1		    |      | Supp B	     | Null	            |  Not Allowed |
       |========|==============|================|======|=============|==================|==============|
       | Case 3 |Supp A	       | Site 1		    |  Y   | Supp B	     | Null	            |  Allowed(**) |
       |========|==============|================|======|=============|==================|==============|


       (**) Case 3: For this case, a new supplier site is created with the site id "Site 1" under Supp B,
		    So this essentially means that it is the same as Case 2 in the table but
		    with the same site code.

	     Case 1 : From supplier(p_dup_vendor_id) and To supplier(p_vendor_id) are same
			      and From suppl site(p_dup_vendor_site_id) and To supplier site(p_vendor_site_id)
		          are different that is we are mergeing to sites which belongs to same supllier.

	     Case 2 : From supplier(p_dup_vendor_id) and To supplier(p_vendor_id) are different
			      and From suppl site(p_dup_vendor_site_id) and To supplier site(p_vendor_site_id)
		          are different that is we are mergeing to sites which belongs to different supllier,
		          which means we are transferring a site from Supplier1 to Supplier2.

                  We will have two scenario in this case as below,
                  a) Site being merged is not the last active site for supplier being merged.
                       In this case Supp A will remain Active and only users that are associated with
                       the Site 1 will be moved over to SuppB Site 2.
                       Also, there should not be an update for records that don't refer the 'from'
                       site being merged as the supplier is still active.

                  b) Site being merged is the last active site for supplier being merged.
                     In this case Supplier A will become inactive and all users associated with supplier A
                     will move to Supplier B.

	     Case 3 : From supplier(p_dup_vendor_id) and To supplier(p_vendor_id) are different
			      To supplier site(p_vendor_site_id) is null and copy flag is enabled, i.e. copy
			      From Supplier Site(p_dup_vendor_site_id) under To Supplier(p_vendor_id).

	  Implementation Approch :
      =======================

	     Case 1: We will update vendor_site_id, vendor_site code for all tables that have reference
		         to vendor_site_id.

	     Case 2: The implementation will be as below for scenario a and b described above,

                 a) Update vendor_id, trading_partner_id, vendor_site_id
                    on all tables with reference to these cols
                    where vendor_id = p_dup_vendor_id
                    and trading_partner_id = p_dup_trading_partner_id
                    and (vendor_site_id = p_dup_vendor_site_id ).

                    The record should not be updated, if the vendor_site_id
                    is NOT populated.

                 b) Update vendor_id, trading_partner_id, vendor_site_id,
                    on all tables with reference to these cols
                    where vendor_id = p_dup_vendor_id
                    and trading_partner_id = p_dup_trading_partner_id
                    and vendor_site_id = p_dup_vendor_site_id

                    The record should be updated even if vendor_site_id is
                    not populated.

	    Case 3:  Here new supplier site will be created with the site code same as of
		         From Supplier Site(p_dup_vendor_site_id) under To Supplier(p_vendor_id).
		         This is the same as Case 2 but with the same site code.
    */

	  -- Get the vendor information for the site we're merging to
      GET_MERGE_TO_VENDOR_INFO(p_vendor_id	=> p_vendor_id,
			       p_vendor_site_id => p_vendor_site_id,
			       x_return_status	=> p_return_status,
			       x_msg_count	=> p_msg_count,
			       x_msg_data	=> p_msg_data,
			       x_trading_partner_name => x_trading_partner_name,
			       x_vendor_site_code => x_vendor_site_code);

     l_progress := 105;
     fnd_file.put_line (fnd_file.log, l_progress|| ' Done GET_MERGE_TO_VENDOR_INFO ');

     --{
     IF (p_vendor_id = p_dup_vendor_id and p_vendor_site_id <> p_dup_vendor_site_id) THEN
	   BEGIN --{
	      l_progress := 106;
          fnd_file.put_line (fnd_file.log, l_progress|| ' Merge Site From Same Suppliers ');
				   /* Case 1*/

	      MERGE_SAME_VENDOR_DIFF_SITES(p_vendor_id	     => p_vendor_id,
					                  p_vendor_site_id   => p_vendor_site_id,
					                  p_vendor_site_code   => x_vendor_site_code,
					                  p_dup_vendor_id	 => p_dup_vendor_id,
					                  p_dup_vendor_site_id	 => p_dup_vendor_site_id,
					                  x_return_status	  => p_return_status,
					                  x_msg_count	=> p_msg_count,
					                  x_msg_data	=> p_msg_data);
	   END; --}
     ELSE IF (p_vendor_id <> p_dup_vendor_id) THEN
	   BEGIN --{
				  /* Case 2 and Case3 */
	       l_progress := 107;

	       l_num_active_sites := GET_ACTIVE_SITE_COUNT(p_dup_vendor_id, p_dup_vendor_site_id);

	       l_progress := 108;
           fnd_file.put_line (fnd_file.log, l_progress|| 'AFter getting active site count '||l_num_active_sites);

	       IF (l_num_active_sites > 0) THEN
				  /* Case 2b*/
               fnd_file.put_line (fnd_file.log, l_progress|| ' Merge diff Suppliers - Not last Site');

	           MERGE_DIFF_VENDOR_AND_SITE(p_trading_partner_id => p_party_id,
				                     p_dup_trading_partner_id => p_dup_party_id,
				                     p_vendor_id      => p_vendor_id,
				                     p_vendor_site_id => p_vendor_site_id,
				                     p_vendor_site_code => x_vendor_site_code,
				                     p_dup_vendor_id	  => p_dup_vendor_id,
				                     p_dup_vendor_site_id => p_dup_vendor_site_id,
				                     p_trading_partner_name => x_trading_partner_name,
				                     x_return_status => p_return_status,
				                     x_msg_count      => p_msg_count,
				                     x_msg_data       => p_msg_data);
	           l_progress := 109;
               fnd_file.put_line (fnd_file.log, l_progress|| 'After MERGE_DIFF_VENDOR_AND_SITE');
	       ELSE
				  /* Case 2a*/

               fnd_file.put_line (fnd_file.log, l_progress|| ' Merge diff Suppliers - Merge last Site');

	           MERGE_DIFF_VENDOR_LAST_SITE(p_trading_partner_id => p_party_id,
				                      p_dup_trading_partner_id => p_dup_party_id,
				                      p_vendor_id      => p_vendor_id,
				                      p_vendor_site_id => p_vendor_site_id,
				                      p_vendor_site_code => x_vendor_site_code,
				                      p_dup_vendor_id	  => p_dup_vendor_id,
				                      p_dup_vendor_site_id => p_dup_vendor_site_id,
				                      p_trading_partner_name => x_trading_partner_name,
				                      x_return_status => p_return_status,
				                      x_msg_count      => p_msg_count,
				                      x_msg_data       => p_msg_data);
	           l_progress := 110;
               fnd_file.put_line (fnd_file.log, l_progress|| 'After Merge diff Suppliers - Merge last Site');
	       END IF;

           /*
             After the merge there can be cases where this table
             does not have records for the bids that got updated
             due to the merge and hence we might need to insert
             extra rows here.
             Same logic as in the upgrade
           */

           UPDATE_SUPPLIER_ACTIVITY(p_dup_trading_partner_id => p_dup_party_id,
				                     x_return_status => p_return_status,
				                     x_msg_count      => p_msg_count,
				                     x_msg_data       => p_msg_data);

	       l_progress := 111;
           fnd_file.put_line (fnd_file.log, l_progress|| 'After UPDATE_SUPPLIER_ACTIVITY ...');

	     EXCEPTION WHEN OTHERS THEN
		  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	      l_progress := 000;

          fnd_file.put_line (fnd_file.log, l_progress|| 'In Exception ...'||' SQLERRM = ' || SQLERRM);
          fnd_file.put_line (fnd_file.log, l_progress|| 'In Exception ...'||' SQLCODE = '|| SQLCODE);

		  IF (G_FND_DEBUG = 'Y') THEN
		     IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
			   FND_LOG.STRING(log_level => FND_LOG.LEVEL_EXCEPTION,
					  module => g_pkg_name || l_procedure_name,
					  message => 'Exception '
						     ||' l_progress = '||l_progress
						     ||' SQLERRM = ' || SQLERRM
						     ||' SQLCODE = '|| SQLCODE);
		     END IF;
		  END IF;

		  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
		  THEN
		      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, g_api_name);
		  END IF;

		  FND_MSG_PUB.Count_And_Get( p_count  => p_msg_count,
					                 p_data   => p_msg_data);
      END; --}
    END IF;
  END IF;
    --}

	 l_progress := 112;
     fnd_file.put_line (fnd_file.log, l_progress|| ' Before PON_CONTERMS_UTL_PVT.updateDelivOnVendorMerge call.... ');

      -- if there are any conterms and if
      -- contracts is installed, then merge the
      -- deliverables for these 2 vendors

      PON_CONTERMS_UTL_PVT.updateDelivOnVendorMerge(p_dup_vendor_id,
						    p_dup_vendor_site_id,
						    p_vendor_id,
						    p_vendor_site_id,
						    p_msg_data,
						    p_msg_count,
						    p_return_status);

       l_progress := 112;

       fnd_file.put_line (fnd_file.log, l_progress|| ' After PON_CONTERMS_UTL_PVT.updateDelivOnVendorMerge call.... ');
       fnd_file.put_line (fnd_file.log, l_progress|| 'End of PON_VENDORMERGE_GRP.MERGE_VENDOR ');

 EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	 p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     l_progress := 1000;
     fnd_file.put_line (fnd_file.log, l_progress|| 'In Exception ...'||' SQLERRM = ' || SQLERRM);
     fnd_file.put_line (fnd_file.log, l_progress|| 'In Exception ...'||' SQLCODE = '|| SQLCODE);

	 FND_MSG_PUB.Count_And_Get(p_count => p_msg_count,
					       p_data  => p_msg_data);
     WHEN OTHERS THEN
	  p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  IF (G_FND_DEBUG = 'Y') THEN
	     IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		   FND_LOG.STRING(log_level => FND_LOG.LEVEL_EXCEPTION,
				  module => g_pkg_name || l_procedure_name,
				  message => 'Exception '
					     ||' l_progress = '||l_progress
					     ||' SQLERRM = ' || SQLERRM
					     ||' SQLCODE = '|| SQLCODE);
	     END IF;
	  END IF;

	  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, g_api_name);
	  END IF;

	  FND_MSG_PUB.Count_And_Get(p_count  => p_msg_count,
							p_data	 => p_msg_data);
  END; --}

		  /*	     END OF MAIN ROUTINE - MERGE_VENDOR       */

		  /*	    PROCEDURE AND FUNCTION CALL STARTS	      */

  FUNCTION GET_ACTIVE_SITE_COUNT(p_dup_vendor_id IN NUMBER,
						 p_dup_vendor_site_id  IN NUMBER)
    RETURN NUMBER
    AS
	l_num_active_sites NUMBER;
    BEGIN
      -- select count of active sites (besides the site being merged)

      -- Note: Verify if we need to consider any ap table instead of
      -- po_vendor_sites_all to check active sites.

      SELECT count(*)
      INTO l_num_active_sites
      FROM po_vendor_sites_all
      WHERE vendor_id = p_dup_vendor_id
	    AND vendor_site_id <> p_dup_vendor_site_id
	    AND nvl(inactive_date, sysdate+1) > sysdate;
     return l_num_active_sites;
    END;

   PROCEDURE GET_MERGE_TO_VENDOR_INFO(p_vendor_id IN NUMBER,
				     p_vendor_site_id IN NUMBER,
				     x_return_status IN OUT NOCOPY VARCHAR2 ,
				     x_msg_count IN OUT NOCOPY NUMBER,
				     x_msg_data IN OUT NOCOPY VARCHAR2,
				     x_trading_partner_name OUT NOCOPY VARCHAR2,
				     x_vendor_site_code OUT NOCOPY VARCHAR2)
    IS
	 l_procedure_name   VARCHAR2(30) := 'GET_MERGE_TO_VENDOR_INFO';

    BEGIN  --{
	   -- select the vendor information for the site we're merging to
	   SELECT pv.vendor_name, pvs.vendor_site_code
	     INTO x_trading_partner_name, x_vendor_site_code
	     FROM po_vendors pv, po_vendor_sites_all pvs
	    WHERE pv.vendor_id = p_vendor_id
		  AND pv.vendor_id = pvs.vendor_id
		  AND pvs.vendor_site_id = p_vendor_site_id;

   EXCEPTION WHEN NO_DATA_FOUND THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      fnd_file.put_line (fnd_file.log,  'In Exception - GET_MERGE_TO_VENDOR_INFO ...'||' SQLERRM = ' || SQLERRM);
      fnd_file.put_line (fnd_file.log,  'In Exception - GET_MERGE_TO_VENDOR_INFO ...'||' SQLCODE = '|| SQLCODE);

	  IF (G_FND_DEBUG = 'Y') THEN
	     IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		   FND_LOG.STRING(log_level => FND_LOG.LEVEL_EXCEPTION,
				  module => g_pkg_name || l_procedure_name,
				  message => 'Exception '
					     || ' p_vendor_site_id  '  || p_vendor_site_id
					     || ' p_vendor_id	    '  || p_vendor_id
					     || ' SQLCODE = '|| SQLCODE
					     || ' SQLERRM = ' || SQLERRM);
	     END IF;
	  END IF;

	  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	  THEN
	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, g_api_name);
	  END IF;

	  FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count,
						         p_data   => x_msg_data);
   END; --}


PROCEDURE MERGE_SAME_VENDOR_DIFF_SITES(p_vendor_id	       IN   NUMBER,
						              p_vendor_site_id	   IN	NUMBER,
						              p_vendor_site_code   IN   VARCHAR2,
						              p_dup_vendor_id	   IN	NUMBER,
						              p_dup_vendor_site_id IN   NUMBER,
						              x_return_status	   IN OUT NOCOPY  VARCHAR2,
						              x_msg_count	       IN OUT NOCOPY  NUMBER,
						              x_msg_data		   IN OUT NOCOPY  VARCHAR2)
  IS
    l_procedure_name   VARCHAR2(30) := 'MERGE_SAME_VENDOR_DIFF_SITES';
    l_progress				NUMBER;
    l_trading_partner_id    NUMBER;
    l_dup_vendor_site_code		      po_vendor_sites_all.vendor_site_code%type;

  BEGIN --{

       /*
	   Followling table will be updated while merging at SITE Level.
	   1.  pon_bid_headers
	   2.  pon_bidding_parties
	   3.  pon_party_line_exclusions
	   4.  pon_pf_supplier_formula
       */

      l_progress := 301;
      fnd_file.put_line (fnd_file.log, l_progress|| 'Start : MERGE_SAME_VENDOR_DIFF_SITES');

      /* Bug 4948321 : FTS for pon_bid_headers due to vendorId comparision.
         - Retrieve trading_partner_id from ap_suppliers and use that
           in update query for pon_bid_headers.
      */

      SELECT party_id
        INTO l_trading_partner_id
        FROM ap_suppliers
       WHERE vendor_id=p_vendor_id;

      UPDATE pon_bid_headers pbh1
      SET pbh1.vendor_site_id = p_vendor_site_id,
	      pbh1.vendor_site_code = decode(pbh1.vendor_site_code,null,null,'-1','-1',p_vendor_site_code),
	      pbh1.last_updated_by = -1,
	      pbh1.last_update_date = sysdate
      WHERE pbh1.trading_partner_id = l_trading_partner_id
	    AND pbh1.vendor_site_id = p_dup_vendor_site_id
	    AND NOT EXISTS (SELECT 'DUPLICATE'
			              FROM pon_bid_headers pbh2
			             WHERE pbh2.auction_header_id = pbh1.auction_header_id
			               AND pbh2.vendor_id = pbh1.vendor_id
			               AND pbh2.trading_partner_contact_id = pbh1.trading_partner_contact_id
			               AND pbh2.trading_partner_id = pbh1.trading_partner_id
			               AND pbh2.vendor_site_id = p_vendor_site_id);

      l_progress := 302;
      fnd_file.put_line (fnd_file.log, l_progress|| 'Done : pon_bid_headers');

      -- Bug 5100555
      -- This is done to update site code for reusable invitation list
      -- putting separate query to take care of duplication of supplier
      -- in list.

	   SELECT pvs.vendor_site_code
	     INTO l_dup_vendor_site_code
	     FROM po_vendors pv, po_vendor_sites_all pvs
	    WHERE pv.vendor_id = p_dup_vendor_id
		  AND pv.vendor_id = pvs.vendor_id
		  AND pvs.vendor_site_id = p_dup_vendor_site_id;

       UPDATE pon_bidding_parties pbp1
          set pbp1.vendor_site_id = decode(pbp1.vendor_site_id , -1,-1, p_vendor_site_id),
              pbp1.vendor_site_code = decode(pbp1.vendor_site_code,'-1','-1',p_vendor_site_code)
       WHERE pbp1.trading_partner_id = l_trading_partner_id
         AND ((pbp1.vendor_site_id = p_dup_vendor_site_id and pbp1.list_id  = -1)
              OR
              (pbp1.vendor_site_code = l_dup_vendor_site_code and pbp1.list_id  <> -1)
              OR
              ( pbp1.vendor_site_code = l_dup_vendor_site_code
                and pbp1.auction_header_id is not null
                and exists( select 1 from pon_auction_headers_all pah
                           where pah.auction_header_id = pbp1.auction_header_id
                           and pah.global_template_flag='Y' )
              )
             )
         AND NOT EXISTS (SELECT 'DUPLICATE'
                           FROM pon_bidding_parties pbp2
                           WHERE pbp2.auction_header_id = pbp1.auction_header_id
                           AND pbp2.list_id = pbp1.list_id
                           AND pbp2.trading_partner_id = pbp1.trading_partner_id
                           AND decode(pbp2.vendor_site_code,'-1',p_vendor_site_code,pbp2.vendor_site_code) = p_vendor_site_code
                           AND decode(pbp2.vendor_site_id,-1, p_vendor_site_id,pbp2.vendor_site_id) = p_vendor_site_id);

      l_progress := 303;
      fnd_file.put_line (fnd_file.log, l_progress|| 'Done : pon_bidding_parties');

     UPDATE pon_party_line_exclusions pple1
	    SET pple1.vendor_site_id = p_vendor_site_id,
            pple1.last_updated_by = -1,
            pple1.last_update_date = sysdate
      WHERE pple1.vendor_site_id = p_dup_vendor_site_id
      AND NOT EXISTS (SELECT 'DUPLICATE'
			            FROM pon_party_line_exclusions pple2
			           WHERE pple2.auction_header_id = pple1.auction_header_id
			             AND pple2.line_number = pple1.line_number
			             AND pple2.trading_partner_id = pple1.trading_partner_id
			             AND pple2.vendor_site_id = p_vendor_site_id);

      l_progress := 304;
      fnd_file.put_line (fnd_file.log, l_progress|| 'Done : pon_party_line_exclusions');

     UPDATE pon_pf_supplier_formula ppsf1
	    SET ppsf1.vendor_site_id =  p_vendor_site_id
      WHERE ppsf1.vendor_site_id = p_dup_vendor_site_id
       AND NOT EXISTS (SELECT 'DUPLICATE'
			             FROM pon_pf_supplier_formula ppsf2
			            WHERE ppsf2.auction_header_id = ppsf1.auction_header_id
			             AND ppsf2.trading_partner_id = ppsf1.trading_partner_id
			             AND ppsf2.vendor_site_id = p_vendor_site_id);

      l_progress := 305;
      fnd_file.put_line (fnd_file.log, l_progress|| 'Done : pon_pf_supplier_formula');

     EXCEPTION WHEN NO_DATA_FOUND THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      fnd_file.put_line (fnd_file.log, l_progress || 'In Exception - MERGE_SAME_VENDOR_DIFF_SITES...'||' SQLERRM = ' || SQLERRM);
      fnd_file.put_line (fnd_file.log, l_progress || 'In Exception - MERGE_SAME_VENDOR_DIFF_SITES...'||' SQLCODE = '|| SQLCODE);

	  IF (G_FND_DEBUG = 'Y') THEN
	     IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		   FND_LOG.STRING(log_level => FND_LOG.LEVEL_EXCEPTION,
				  module => g_pkg_name || l_procedure_name,
				  message => 'Exception SQLERRM = ' || SQLERRM
					     ||' SQLCODE = '|| SQLCODE);
	     END IF;
	  END IF;

	  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	  THEN
	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, g_api_name);
	  END IF;

	  FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count,
				     p_data   => x_msg_data);

  END; --}


PROCEDURE MERGE_DIFF_VENDOR_AND_SITE(p_trading_partner_id		IN   NUMBER,
						p_dup_trading_partner_id	IN   NUMBER,
						p_vendor_id			IN   NUMBER,
						p_vendor_site_id		IN   NUMBER,
						p_vendor_site_code		IN   VARCHAR2,
						p_dup_vendor_id 		IN   NUMBER,
						p_dup_vendor_site_id		IN   NUMBER,
						p_trading_partner_name		IN   VARCHAR2,
						x_return_status 		IN  OUT NOCOPY	VARCHAR2,
						x_msg_count			IN OUT NOCOPY  NUMBER,
						x_msg_data			IN OUT NOCOPY	VARCHAR2)
  IS
    l_procedure_name   VARCHAR2(30) := 'MERGE_DIFF_VENDOR_AND_SITE';
    l_progress				NUMBER;
    l_dup_vendor_site_code		      po_vendor_sites_all.vendor_site_code%type;

  BEGIN --{

    /*     CASE 2b - site being merged is not the last site

	       Followling table will be updated while merging at Vendor level.
	       1. pon_bid_item_prices
	       2. pon_bid_headers
	       3. pon_bidding_parties
	       4. pon_party_line_exclusions
	       5. pon_pf_supplier_formula
     */

      l_progress := 500;
      fnd_file.put_line (fnd_file.log, l_progress|| ' Start : MERGE_DIFF_VENDOR_AND_SITE');

      UPDATE pon_bid_item_prices pbip1
         SET pbip1.bid_trading_partner_id = p_trading_partner_id,
	         pbip1.last_updated_by = -1,
	         pbip1.last_update_date = sysdate
      WHERE pbip1.bid_trading_partner_id = p_dup_trading_partner_id
      AND pbip1.bid_number IN (SELECT bid_number
				                FROM pon_bid_headers pbh1
				               WHERE pbh1.trading_partner_id = p_dup_trading_partner_id
				                 AND pbh1.vendor_id = p_dup_vendor_id
				                 AND pbh1.vendor_site_id=  p_dup_vendor_site_id
				                 AND NOT EXISTS (SELECT 'DUPLICATE'
						                           FROM pon_bid_headers pbh2
						                           WHERE pbh2.auction_header_id = pbh1.auction_header_id
						                           AND pbh2.vendor_id = p_vendor_id
						                           AND pbh2.vendor_site_id = p_vendor_site_id
						                           AND pbh2.trading_partner_id = p_trading_partner_id
						                           AND pbh2.trading_partner_contact_id = pbh1.trading_partner_contact_id)
                            );

      l_progress := 501;
      fnd_file.put_line (fnd_file.log, l_progress|| ' Done: pon_bid_item_prices ');

      UPDATE pon_bid_headers pbh1
         SET pbh1.trading_partner_id = p_trading_partner_id,
	         pbh1.trading_partner_name = p_trading_partner_name,
	         pbh1.vendor_id = p_vendor_id,
	         pbh1.vendor_site_id = p_vendor_site_id,
	         pbh1.vendor_site_code = p_vendor_site_code,
	         pbh1.last_updated_by = -1,
	         pbh1.last_update_date = sysdate
      WHERE pbh1.trading_partner_id = p_dup_trading_partner_id
       AND  pbh1.vendor_id = p_dup_vendor_id
       AND  pbh1.vendor_site_id = p_dup_vendor_site_id
       AND NOT EXISTS (SELECT 'DUPLICATE'
			             FROM pon_bid_headers pbh2
			            WHERE pbh2.auction_header_id = pbh1.auction_header_id
			              AND pbh2.vendor_id = p_vendor_id
			              AND pbh2.vendor_site_id = p_vendor_site_id
			              AND pbh2.trading_partner_id = p_trading_partner_id
			              AND pbh2.trading_partner_contact_id = pbh1.trading_partner_contact_id);

      l_progress := 502;
      fnd_file.put_line (fnd_file.log, l_progress|| ' Done: pon_bid_headers');

      -- Bug 5100555
      -- This is done to update site code for reusable invitation list
      -- putting separate query to take care of duplication of supplier
      -- in list.

	   SELECT pvs.vendor_site_code
	     INTO l_dup_vendor_site_code
	     FROM po_vendors pv, po_vendor_sites_all pvs
	    WHERE pv.vendor_id = p_dup_vendor_id
		  AND pv.vendor_id = pvs.vendor_id
		  AND pvs.vendor_site_id = p_dup_vendor_site_id;

      UPDATE pon_bidding_parties pbp1
         SET pbp1.trading_partner_id = p_trading_partner_id,
	         pbp1.trading_partner_name = p_trading_partner_name,
	         pbp1.vendor_site_code = decode(pbp1.vendor_site_code,'-1','-1',p_vendor_site_code),
             pbp1.vendor_site_id = decode(vendor_site_id , -1,-1, p_vendor_site_id),
	         pbp1.last_updated_by = -1,
	         pbp1.last_update_date = sysdate
       WHERE pbp1.trading_partner_id = p_dup_trading_partner_id
         AND ((pbp1.vendor_site_id = p_dup_vendor_site_id and pbp1.list_id  = -1)
              OR
              (pbp1.vendor_site_code = l_dup_vendor_site_code and pbp1.list_id  <> -1)
              OR
              ( pbp1.vendor_site_code = l_dup_vendor_site_code
                and pbp1.auction_header_id is not null
                and exists( select 1 from pon_auction_headers_all pah
                           where pah.auction_header_id = pbp1.auction_header_id
                           and pah.global_template_flag='Y' )
              )
             )
         AND NOT EXISTS (SELECT 'DUPLICATE'
			             FROM pon_bidding_parties pbp2
                         WHERE pbp2.auction_header_id = pbp1.auction_header_id
                           AND pbp2.list_id = pbp1.list_id
                           AND decode(pbp2.vendor_site_code,'-1',p_vendor_site_code,pbp2.vendor_site_code) = p_vendor_site_code
                           AND pbp2.trading_partner_id = p_trading_partner_id
                           AND decode(pbp2.vendor_site_id,-1, p_vendor_site_id,pbp2.vendor_site_id) = p_vendor_site_id);

      l_progress := 503;
      fnd_file.put_line (fnd_file.log, l_progress|| ' Done: pon_bidding_parties');

     UPDATE pon_party_line_exclusions pple1
        SET pple1.trading_partner_id = p_trading_partner_id,
	        pple1.vendor_site_id = p_vendor_site_id,
            pple1.last_updated_by = -1,
            pple1.last_update_date = sysdate
     WHERE pple1.trading_partner_id = p_dup_trading_partner_id
       AND pple1.vendor_site_id =  p_dup_vendor_site_id
       AND NOT EXISTS (SELECT 'DUPLICATE'
			             FROM pon_party_line_exclusions pple2
			            WHERE pple2.auction_header_id = pple1.auction_header_id
			              AND pple2.trading_partner_id = p_trading_partner_id
			              AND pple2.vendor_site_id =p_vendor_site_id);

     l_progress := 505;
     fnd_file.put_line (fnd_file.log, l_progress|| ' Done: pon_party_line_exclusions');

     UPDATE pon_pf_supplier_formula  ppsf1
     SET  ppsf1.trading_partner_id = p_trading_partner_id,
	      ppsf1.vendor_site_id = p_vendor_site_id,
          ppsf1.last_updated_by = -1,
          ppsf1.last_update_date = sysdate
     WHERE ppsf1.trading_partner_id = p_dup_trading_partner_id
	   AND ppsf1.vendor_site_id = p_dup_vendor_site_id
	   AND NOT EXISTS (SELECT 'DUPLICATE'
		                 FROM pon_pf_supplier_formula ppsf2
		                WHERE ppsf2.auction_header_id = ppsf1.auction_header_id
		                  AND ppsf2.trading_partner_id = p_trading_partner_id
		                  AND ppsf2.vendor_site_id = p_vendor_site_id);
    l_progress := 506;
    fnd_file.put_line (fnd_file.log, l_progress|| ' Done: pon_pf_supplier_formula');

     EXCEPTION WHEN NO_DATA_FOUND THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      fnd_file.put_line (fnd_file.log, l_progress || 'In Exception - MERGE_DIFF_VENDOR_AND_SITE...'||' SQLERRM = ' || SQLERRM);
      fnd_file.put_line (fnd_file.log, l_progress || 'In Exception - MERGE_DIFF_VENDOR_AND_SITE...'||' SQLCODE = '|| SQLCODE);

	  IF (G_FND_DEBUG = 'Y') THEN
	     IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		   FND_LOG.STRING(log_level => FND_LOG.LEVEL_EXCEPTION,
				  module => g_pkg_name || l_procedure_name,
				  message => 'Exception SQLERRM = ' || SQLERRM
					     ||' SQLCODE = '|| SQLCODE);
	     END IF;
	  END IF;

	  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	  THEN
	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, g_api_name);
	  END IF;

	  FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count,
				     p_data   => x_msg_data);


  END; --}

PROCEDURE MERGE_DIFF_VENDOR_LAST_SITE(p_trading_partner_id		IN   NUMBER,
						p_dup_trading_partner_id	IN   NUMBER,
						p_vendor_id			IN   NUMBER,
						p_vendor_site_id		IN   NUMBER,
						p_vendor_site_code		IN   VARCHAR2,
						p_dup_vendor_id 		IN   NUMBER,
						p_dup_vendor_site_id		IN   NUMBER,
						p_trading_partner_name		IN   VARCHAR2,
						x_return_status 		IN  OUT NOCOPY	VARCHAR2,
						x_msg_count			IN OUT NOCOPY  NUMBER,
						x_msg_data			IN OUT NOCOPY	VARCHAR2)
  IS
    l_procedure_name   VARCHAR2(35) := 'MERGE_DIFF_VENDOR_LAST_SITE';
    l_progress				NUMBER;
    l_dup_vendor_site_code		      po_vendor_sites_all.vendor_site_code%type;
  BEGIN --{

    /*     CASE 2a - site being merged is the last site

	       Followling table will be updated while merging last site

	       1. pon_bid_item_prices
	       2. pon_bid_headers
	       3. pon_bidding_parties
	       4. pon_party_line_exclusions
	       5. pon_pf_supplier_formula
	       6. pon_supplier_access
	       7. pon_threads
	       8. pon_thread_entries
	       9. pon_te_recipients
	      10. pon_supplier_activities
          11. pon_acknowledgements
     */

      l_progress := 701;
      fnd_file.put_line (fnd_file.log, l_progress|| 'Start : MERGE_DIFF_VENDOR_LAST_SITE ');

      UPDATE pon_bid_item_prices pbip1
         SET pbip1.bid_trading_partner_id = p_trading_partner_id,
	         pbip1.last_updated_by = -1,
	         pbip1.last_update_date = sysdate
      WHERE pbip1.bid_trading_partner_id = p_dup_trading_partner_id
      AND pbip1.bid_number IN (SELECT bid_number
				                FROM pon_bid_headers pbh1
				               WHERE pbh1.trading_partner_id = p_dup_trading_partner_id
				                 AND pbh1.vendor_id = p_dup_vendor_id
				                 AND pbh1.vendor_site_id =  decode(pbh1.vendor_site_id,-1,-1,p_dup_vendor_site_id)
				                 AND NOT EXISTS (SELECT 'DUPLICATE'
						                           FROM pon_bid_headers pbh2
						                           WHERE pbh2.auction_header_id = pbh1.auction_header_id
						                           AND pbh2.vendor_id = p_vendor_id
							                       AND pbh2.vendor_site_id=  decode(pbh2.vendor_site_id,-1,-1,p_vendor_site_id)
						                           AND pbh2.trading_partner_id = p_trading_partner_id
						                           AND pbh2.trading_partner_contact_id = pbh1.trading_partner_contact_id)
                            );


      l_progress := 702;
      fnd_file.put_line (fnd_file.log, l_progress|| 'Done pon_bid_item_prices ');

      UPDATE pon_acknowledgements
      SET trading_partner_id = p_trading_partner_id,
	      last_updated_by = -1,
	      last_update_date = sysdate
      WHERE trading_partner_id = p_dup_trading_partner_id ;


      l_progress := 703;
      fnd_file.put_line (fnd_file.log, l_progress|| 'Done pon_acknowledgements');

      UPDATE pon_bid_headers pbh1
         SET pbh1.trading_partner_id = p_trading_partner_id,
	        pbh1.trading_partner_name = p_trading_partner_name,
	        pbh1.vendor_id = p_vendor_id,
	        pbh1.vendor_site_id = decode(pbh1.vendor_site_id,-1,-1,p_vendor_site_id),
	        pbh1.vendor_site_code = decode(pbh1.vendor_site_code,null,null,'-1','-1',p_vendor_site_code),
	        pbh1.last_updated_by = -1,
	        pbh1.last_update_date = sysdate
      WHERE pbh1.trading_partner_id = p_dup_trading_partner_id
       AND  pbh1.vendor_id = p_dup_vendor_id
       AND  pbh1.vendor_site_id = decode(pbh1.vendor_site_id,-1,-1,p_dup_vendor_site_id)
       AND NOT EXISTS (SELECT 'DUPLICATE'
			             FROM pon_bid_headers pbh2
			            WHERE pbh2.auction_header_id = pbh1.auction_header_id
			              AND pbh2.vendor_id = p_vendor_id
			              AND decode(pbh2.vendor_site_id,-1,p_vendor_site_id,pbh2.vendor_site_id) = p_vendor_site_id
			              AND decode(pbh2.vendor_site_code,'-1',p_vendor_site_code,null,p_vendor_site_code,pbh2.vendor_site_code) = p_vendor_site_code
			              AND pbh2.trading_partner_id = p_trading_partner_id
			              AND pbh2.trading_partner_contact_id = pbh1.trading_partner_contact_id);

      l_progress := 704;
      fnd_file.put_line (fnd_file.log, l_progress|| 'Done pon_bid_headers');

	   SELECT pvs.vendor_site_code
	     INTO l_dup_vendor_site_code
	     FROM po_vendors pv, po_vendor_sites_all pvs
	    WHERE pv.vendor_id = p_dup_vendor_id
		  AND pv.vendor_id = pvs.vendor_id
		  AND pvs.vendor_site_id = p_dup_vendor_site_id;

      UPDATE pon_bidding_parties pbp1
         SET pbp1.trading_partner_id = p_trading_partner_id,
	         pbp1.trading_partner_name = p_trading_partner_name,
	         pbp1.vendor_site_id = decode(pbp1.vendor_site_id,-1,-1,p_vendor_site_id),
	         pbp1.vendor_site_code = decode(pbp1.vendor_site_code,'-1','-1',p_vendor_site_code),
	         pbp1.last_updated_by = -1,
	         pbp1.last_update_date = sysdate
       WHERE pbp1.trading_partner_id = p_dup_trading_partner_id
         AND ((pbp1.vendor_site_id=decode(pbp1.vendor_site_id,-1,-1,p_dup_vendor_site_id) and pbp1.list_id = -1)
              OR
              (pbp1.vendor_site_code = decode(pbp1.vendor_site_code,'-1','-1',l_dup_vendor_site_code) and pbp1.list_id  <> -1)
              OR
              ( pbp1.vendor_site_code = decode(pbp1.vendor_site_code,'-1','-1',l_dup_vendor_site_code)
                and pbp1.auction_header_id is not null
                and exists( select 1 from pon_auction_headers_all pah
                           where pah.auction_header_id = pbp1.auction_header_id
                           and pah.global_template_flag='Y' )
              )
             )
        AND NOT EXISTS (SELECT 'DUPLICATE'
			             FROM pon_bidding_parties pbp2
			            WHERE pbp2.auction_header_id = pbp1.auction_header_id
                          AND pbp2.list_id = pbp1.list_id
			              AND pbp2.trading_partner_id = p_trading_partner_id
                          AND decode(pbp2.vendor_site_code,'-1',p_vendor_site_code,pbp2.vendor_site_code) = p_vendor_site_code
			              AND pbp2.vendor_site_id = decode(pbp1.vendor_site_id,-1,-1,p_vendor_site_id));

      l_progress := 705;
      fnd_file.put_line (fnd_file.log, l_progress|| 'Done pon_bidding_parties');

     UPDATE pon_party_line_exclusions pple1
        SET pple1.trading_partner_id = p_trading_partner_id,
	        pple1.vendor_site_id = decode(pple1.vendor_site_id,-1,-1,p_vendor_site_id)
     WHERE pple1.trading_partner_id = p_dup_trading_partner_id
       AND pple1.vendor_site_id =  decode(pple1.vendor_site_id,-1,-1,p_dup_vendor_site_id)
       AND NOT EXISTS (SELECT 'DUPLICATE'
			             FROM pon_party_line_exclusions pple2
			            WHERE pple2.auction_header_id = pple1.auction_header_id
			              AND pple2.trading_partner_id = p_trading_partner_id
			              AND pple2.vendor_site_id =decode(pple2.vendor_site_id,-1,-1,p_vendor_site_id));

     l_progress := 707;
     fnd_file.put_line (fnd_file.log, l_progress|| 'Done pon_party_line_exclusions');

     UPDATE pon_pf_supplier_formula  ppsf1
        SET ppsf1.trading_partner_id = p_trading_partner_id,
	        ppsf1.vendor_site_id = decode(ppsf1.vendor_site_id,-1,-1,p_vendor_site_id),
            ppsf1.last_updated_by = -1,
            ppsf1.last_update_date = sysdate
     WHERE ppsf1.trading_partner_id = p_dup_trading_partner_id
	   AND ppsf1.vendor_site_id = decode(ppsf1.vendor_site_id,-1,-1,p_dup_vendor_site_id)
	   AND NOT EXISTS (SELECT 'DUPLICATE'
		               FROM pon_pf_supplier_formula ppsf2
		              WHERE ppsf2.auction_header_id = ppsf1.auction_header_id
		                AND ppsf2.trading_partner_id = p_trading_partner_id
		                AND ppsf2.vendor_site_id = decode(ppsf1.vendor_site_id,-1,-1,p_vendor_site_id));

     l_progress := 708;
     fnd_file.put_line (fnd_file.log, l_progress|| 'Done pon_pf_supplier_formula');

    /*
      We are comparing w.r.t AUCTION_HEADER_ID_ORIG_AMEND becuase
      the UK is definied on this field.
    */

    UPDATE pon_supplier_access psa1
       SET psa1.supplier_trading_partner_id = p_trading_partner_id,
	       psa1.last_updated_by = -1,
	       psa1.last_update_date = sysdate
     WHERE psa1.supplier_trading_partner_id = p_dup_trading_partner_id
	   AND NOT EXISTS (SELECT 'DUPLICATE'
		               FROM pon_supplier_access psa2
		              WHERE psa2.auction_header_id_orig_amend = psa1.auction_header_id_orig_amend
		                AND psa2.supplier_trading_partner_id = p_trading_partner_id);

    l_progress := 709;
    fnd_file.put_line (fnd_file.log, l_progress|| 'Done pon_supplier_access');

    /*
      We are comparing w.r.t AUCTION_HEADER_ID_ORIG_AMEND becuase
      the UK is definied on this field.
    */

      UPDATE pon_supplier_activities psa1
	     SET psa1.trading_partner_id = p_trading_partner_id,
	         psa1.last_updated_by = -1,
	         psa1.last_update_date = sysdate
      WHERE trading_partner_id =p_dup_trading_partner_id
      AND NOT EXISTS (SELECT 'DUPLICATE'
		                FROM pon_supplier_activities psa2
		               WHERE psa2.auction_header_id_orig_amend = psa1.auction_header_id_orig_amend
		                 AND psa2.trading_partner_contact_id = psa1.trading_partner_contact_id
		                 AND psa2.last_activity_time = psa1.last_activity_time
		                 AND psa2.trading_partner_id = p_trading_partner_id);

    l_progress := 709;
    fnd_file.put_line (fnd_file.log, l_progress|| 'Done pon_supplier_activities');

     /* Who columns are not in update as we don't have it on table */

      UPDATE pon_threads pt
         SET pt.owner_party_id = p_trading_partner_id
      WHERE  pt.owner_party_id = p_dup_trading_partner_id;

    l_progress := 710;
    fnd_file.put_line (fnd_file.log, l_progress|| 'Done pon_threads');

     /* Who columns are not in update as we don't have it on table */

      UPDATE pon_thread_entries pte
         SET pte.from_company_id = p_trading_partner_id,
             pte.from_company_name = p_trading_partner_name,
             pte.vendor_id= p_vendor_id
       WHERE pte.vendor_id = p_dup_vendor_id
        AND pte.from_company_id = p_dup_trading_partner_id;

    l_progress := 711;
    fnd_file.put_line (fnd_file.log, l_progress|| 'Done pon_thread_entries');

     /* Who columns are not in update as we don't have it on table */

      UPDATE pon_te_recipients ptr
         SET ptr.to_company_id = p_trading_partner_id,
             ptr.to_company_name = p_trading_partner_name
      WHERE  ptr.to_company_id = p_dup_trading_partner_id;

    l_progress := 712;
    fnd_file.put_line (fnd_file.log, l_progress|| 'Done pon_te_recipients');


     EXCEPTION WHEN NO_DATA_FOUND THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      fnd_file.put_line (fnd_file.log, l_progress|| 'In exception - MERGE_DIFF_VENDOR_LAST_SITE SQLERRM '||SQLERRM);
      fnd_file.put_line (fnd_file.log, l_progress|| 'In exception - MERGE_DIFF_VENDOR_LAST_SITE SQLCODE'||SQLCODE);

	  IF (G_FND_DEBUG = 'Y') THEN
	     IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		   FND_LOG.STRING(log_level => FND_LOG.LEVEL_EXCEPTION,
				  module => g_pkg_name || l_procedure_name,
				  message => 'Exception SQLERRM = ' || SQLERRM
					     ||' SQLCODE = '|| SQLCODE);
	     END IF;
	  END IF;

	  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	  THEN
	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, g_api_name);
	  END IF;

	  FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count,
				     p_data   => x_msg_data);

  END; --}

     -- After the merge there can be cases where this table
     -- does not have records for the bids that got updated
     -- due to the merge and hence we might need to insert
     -- extra rows here.
     -- Same logic as in the upgrade

     -- Refer to the Bugs 3940301/4145154 for more information.

 PROCEDURE UPDATE_SUPPLIER_ACTIVITY(p_dup_trading_partner_id IN   NUMBER,
					             x_return_status  IN  OUT NOCOPY	VARCHAR2,
					             x_msg_count	  IN OUT NOCOPY  NUMBER,
					             x_msg_data	      IN OUT NOCOPY	VARCHAR2)
 IS
 l_procedure_name VARCHAR2(30) := 'UPDATE_SUPPLIER_ACTIVITY';
 BEGIN --{

	INSERT INTO PON_SUPPLIER_ACTIVITIES
	(
	  auction_header_id_orig_amend,
	  trading_partner_contact_id,
	  last_activity_time,
	  auction_header_id,
	  trading_partner_id,
	  session_id,
	  last_activity_code,
	  last_action_flag,
	  creation_date,
	  created_by,
	  last_update_date,
	  last_updated_by,
	  last_update_login
	)
	SELECT
	  ah.auction_header_id_orig_amend,
	  bh.trading_partner_contact_id,
	  bh.creation_date,
	  bh.auction_header_id,
	  bh.trading_partner_id,
	  -1,  -- session id
	  DECODE(bh.bid_status, 'DRAFT', 'CRT_RESP', 'SUBMIT_BID'), -- activity code
	  'Y', -- last action flag
	  SYSDATE,
	  bh.created_by,
	  SYSDATE,
	  bh.last_updated_by,
	  0
	FROM pon_auction_headers_all ah,
	  pon_bid_headers bh
	WHERE bh.trading_partner_id = p_dup_trading_partner_id
	AND ah.auction_header_id = bh.auction_header_id
	AND NOT EXISTS (
		      SELECT NULL
		      FROM pon_supplier_activities psa
		      WHERE psa.auction_header_id_orig_amend = ah.auction_header_id_orig_amend
		      AND psa.trading_partner_id = bh.trading_partner_id
		      AND psa.trading_partner_contact_id = bh.trading_partner_contact_id
		      )
	AND NOT EXISTS
		      (
		      SELECT NULL
		      FROM pon_bid_headers bh2,
			   pon_auction_headers_all ah2
		      WHERE ah2.auction_header_id = bh2.auction_header_id
		      AND ah.auction_header_id_orig_amend = ah2.auction_header_id_orig_amend
		      AND bh2.bid_number > bh.bid_number
		      AND bh2.trading_partner_contact_id = bh.trading_partner_contact_id
		      AND bh2.trading_partner_id = bh.trading_partner_id
		      );
      --
      -- end supplier activities update.
      --

     EXCEPTION WHEN NO_DATA_FOUND THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      fnd_file.put_line (fnd_file.log,  'In exception - UPDATE_SUPPLIER_ACTIVITY SQLERRM '||SQLERRM);
      fnd_file.put_line (fnd_file.log,  'In exception - UPDATE_SUPPLIER_ACTIVITY SQLCODE'||SQLCODE);

	  IF (G_FND_DEBUG = 'Y') THEN
	     IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		   FND_LOG.STRING(log_level => FND_LOG.LEVEL_EXCEPTION,
				  module => g_pkg_name || l_procedure_name,
				  message => 'Exception SQLERRM = ' || SQLERRM
					     ||' SQLCODE = '|| SQLCODE);
	     END IF;
	  END IF;

	  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	  THEN
	      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, g_api_name);
	  END IF;

	  FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count,
				                 p_data   => x_msg_data);

  END; --}

END PON_VENDORMERGE_GRP; --}

/
