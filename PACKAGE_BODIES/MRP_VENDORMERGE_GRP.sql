--------------------------------------------------------
--  DDL for Package Body MRP_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_VENDORMERGE_GRP" AS
/* $Header: MRPGVDRB.pls 120.1 2005/09/06 13:52:38 ichoudhu noship $ */

G_PKG_NAME 	CONSTANT VARCHAR2(30):='MRP_VendorMerge_GRP';

Procedure Merge_Vendor( p_api_version         IN   NUMBER,
                        p_init_msg_list       IN   VARCHAR2 default
                                              FND_API.G_FALSE,
	                p_commit              IN   VARCHAR2 default
                                              FND_API.G_FALSE,
	                p_validation_level    IN   NUMBER  :=
                                              FND_API.G_VALID_LEVEL_FULL,
	                x_return_status       OUT  NOCOPY VARCHAR2,
	                x_msg_count           OUT  NOCOPY NUMBER,
	                x_msg_data            OUT  NOCOPY VARCHAR2,
	                p_vendor_id           IN   NUMBER,
	                p_vendor_site_id      IN   NUMBER,
	                p_dup_vendor_id       IN   NUMBER,
	                p_dup_vendor_site_id  IN   NUMBER             )

IS

        l_api_name	CONSTANT VARCHAR2(30)	:= 'Merge_Vendor';
        l_api_version  	CONSTANT NUMBER 	:= 1.0;
        l_row_count	NUMBER;
        TYPE t_sr_receipt_id IS TABLE OF mrp_sr_receipt_org.sr_receipt_id%TYPE;
        l_sr_receipt_id t_sr_receipt_id;
        l_sourcing_rule_name mrp_sourcing_rules.sourcing_rule_name%TYPE;

        CURSOR c1(receipt_id NUMBER) IS
        SELECT SUM(allocation_percent) , rank
        FROM mrp_sr_source_org
        WHERE sr_receipt_id = receipt_id
        GROUP BY rank
        HAVING sum(allocation_percent) <> 100;
BEGIN

        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;


        -- Check for call compatibility.
         IF NOT FND_API.Compatible_API_Call ( l_api_version  ,
                                              p_api_version  ,
                                              l_api_name     ,
                                              G_PKG_NAME             )
         THEN
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         -- Initialize API message list if necessary.
         -- Initialize message list if p_init_msg_list is set to TRUE.
         IF FND_API.to_Boolean( p_init_msg_list) THEN
                FND_MSG_PUB.initialize;
         END IF;

         UPDATE mrp_sr_source_org mrp1
         SET    mrp1.vendor_id      = p_vendor_id,
  	        mrp1.vendor_site_id = p_vendor_site_id
         WHERE  mrp1.vendor_id      = p_dup_vendor_id              and
   	        mrp1.vendor_site_id = p_dup_vendor_site_id
         AND    not exists
  		(select mrp2.vendor_id
                 from   mrp_sr_source_org mrp2
                 where  mrp2.vendor_id      = p_vendor_id          and
                        mrp2.vendor_site_id = p_vendor_site_id     and
		        mrp2.sr_receipt_id = mrp1.sr_receipt_id) ;

         UPDATE mrp_sr_source_org mrp1
           	SET    mrp1.vendor_id      = p_vendor_id
           	WHERE  mrp1.vendor_id      = p_dup_vendor_id
   		AND    mrp1.vendor_site_id is null
           	AND    not exists
   		       (select mrp2.vendor_id
                        from   mrp_sr_source_org mrp2
                        where  mrp2.vendor_id      = p_vendor_id
                        and    mrp2.vendor_site_id is null
   			and    mrp2.sr_receipt_id = mrp1.sr_receipt_id) ;


         UPDATE mrp_sr_source_org mrp1
              SET mrp1.allocation_percent
   		   = (SELECT sum (mrp3.allocation_percent)
    			 FROM   mrp_sr_source_org mrp3
   			 WHERE  mrp3.sr_receipt_id  = mrp1.sr_receipt_id
                         AND    mrp3.rank = mrp1.rank
   			 AND    mrp3.vendor_id IN
                                (p_vendor_id, p_dup_vendor_id)
  			 AND    mrp3.vendor_site_id IN
  				(p_vendor_site_id, p_dup_vendor_site_id ))
          	WHERE  mrp1.vendor_id      = p_vendor_id
  		AND    mrp1.vendor_site_id = p_vendor_site_id
          	AND    exists
  		       ( select mrp2.vendor_id
                         from   mrp_sr_source_org mrp2
                         where  mrp2.vendor_id      = p_dup_vendor_id
  			 and    mrp2.vendor_site_id = p_dup_vendor_site_id
                         and    mrp2.rank = mrp1.rank
                         and    mrp2.sr_receipt_id = mrp1.sr_receipt_id) ;


         DELETE from mrp_sr_source_org mrp1
   		WHERE  vendor_id      = p_dup_vendor_id
   		AND    vendor_site_id = p_dup_vendor_site_id
         RETURNING sr_receipt_id
         BULK COLLECT INTO l_sr_receipt_id;

	 IF SQL%FOUND THEN
		l_row_count := SQL%ROWCOUNT;
	 ELSE
		l_row_count := 0;
	 END IF;

         -- Prepare message name
         FND_MESSAGE.SET_NAME('MRP','MRP_SR_SOURCE_ORG_DELETED');
	 FND_MESSAGE.SET_TOKEN('ROWS_DELETED',l_row_count);
	 -- Add message to API message list.
	 FND_MSG_PUB.Add;

         IF (l_row_count > 0) THEN
              FOR j IN l_sr_receipt_id.FIRST..l_sr_receipt_id.LAST LOOP
                FOR c1rec in c1(l_sr_receipt_id(j)) LOOP
                  IF c1%FOUND THEN
               	     UPDATE mrp_sourcing_rules
                     SET planning_active = 2
                     WHERE sourcing_rule_id = ( SELECT sourcing_rule_id
                            FROM mrp_sr_receipt_org
                            WHERE sr_receipt_id = l_sr_receipt_id(j))
                     AND planning_active = 1
                     RETURNING sourcing_rule_name INTO l_sourcing_rule_name;

                     IF (SQL%ROWCOUNT > 0) THEN
                        FND_MESSAGE.SET_NAME('MRP','MRP_INVALID_STATUS');
                        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',l_sourcing_rule_name);
                        FND_MSG_PUB.Add;
                     END IF;
                  END IF;
                END LOOP;
              END LOOP;
         END IF;


	 -- Get message count and if 1, return message data.
	 FND_MSG_PUB.Count_And_Get
         (  	p_count         	=>      x_msg_count,
		p_data          	=>      x_msg_data
	 );

EXCEPTION

               WHEN OTHERS THEN
                dbms_output.put_line(sqlerrm);
                ROLLBACK ;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  		FND_MSG_PUB.Count_And_Get
    		       ( p_count         	=>      x_msg_count,
        		 p_data          	=>      x_msg_data
    		       );

END Merge_Vendor;

END MRP_VendorMerge_GRP;


/
