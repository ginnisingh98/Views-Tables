--------------------------------------------------------
--  DDL for Package Body WMS_CYCLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CYCLE_PVT" AS
/* $Header: WMSCYCCB.pls 120.3.12010000.5 2010/05/27 11:08:03 abasheer ship $ */

--  Global constant holding the package name
G_PKG_NAME	   CONSTANT VARCHAR2(30) := 'WMS_Cycle_PVT';

PROCEDURE print_debug(p_err_msg VARCHAR2)
IS
    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   inv_mobile_helper_functions.tracelog
     (p_err_msg   =>  p_err_msg,
      p_module    =>  'WMS_Cycle_PVT',
      p_level     =>  4);

--   dbms_output.put_line(p_err_msg);
END print_debug;

--Added NOCOPY hint to x_return_status,x_msg_count,x_msg_data to comply
--with GSCC File.Sql.39 standard Bug:4410902

/* Bug 7504490 - Modified the procedure. Added the parameter p_pn_id and p_revision
   to create CC entries for an LPN when a short pick was for an allocated lpn */
PROCEDURE Create_Unscheduled_Counts
(  p_api_version              IN            NUMBER   			       ,
   p_init_msg_list            IN            VARCHAR2 := fnd_api.g_false      ,
   p_commit	              IN            VARCHAR2 := fnd_api.g_false      ,
   x_return_status            OUT NOCOPY    VARCHAR2                         ,
   x_msg_count                OUT NOCOPY    NUMBER                           ,
   x_msg_data		      OUT NOCOPY    VARCHAR2                         ,
   p_organization_id	      IN            NUMBER		       	       ,
   p_subinventory	      IN            VARCHAR2                         ,
   p_locator_id		      IN            NUMBER                          ,
   p_inventory_item_id        IN            NUMBER			    ,
   p_lpn_id                   IN            NUMBER                          ,
   p_revision                 IN            VARCHAR2,
   p_cycle_count_header_id    IN            NUMBER DEFAULT NULL   -- For bug # 9751256
)
-- BUG#2867331 added inventory_item_id
IS
l_api_name	            CONSTANT VARCHAR2(30)  := 'Create_Unscheduled_Counts';
l_api_version	            CONSTANT NUMBER	   := 1.0;
l_org                       INV_Validate.ORG;
l_sub                       INV_Validate.SUB;
l_locator                   INV_Validate.LOCATOR;
l_result                    NUMBER;
l_cycle_count_schedule_id   NUMBER;
l_cycle_count_header_id     NUMBER;
l_unscheduled_count_entry   NUMBER;
l_req_id                    NUMBER;
l_zero_count_flag           NUMBER ; --Bug 5236299

/* Bug 7504490 - Added the following variables for Calling the API*/
l_api_version_int           NUMBER := 0.9;
l_interface_rec             MTL_CCEOI_VAR_PVT.INV_CCEOI_TYPE ;
l_interface_id_list         MTL_CCEOI_VAR_PVT.INV_CCEOI_ID_TABLE_TYPE ;
l_errorcode                NUMBER ;

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT	Create_Unscheduled_Counts_PVT;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version	,
					p_api_version	,
					l_api_name      ,
					G_PKG_NAME )
     THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INCOMPATIBLE_API_CALL');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- API body
   /* Validate all inputs */

   IF (l_debug = 1) THEN
      print_debug('Calling Create_Unscheduled_Counts_PVT');
      print_debug('Organization ID: ' || p_organization_id);
      print_debug('Subinventory: ' || p_subinventory);
      print_debug('Locator ID: ' || p_locator_id);
      print_debug('Inventory Item ID: ' || p_inventory_item_id);
      print_debug('Allocated LPN Id: ' || p_lpn_id);
      print_debug('Opp Cycle Count Header Id: ' || p_cycle_count_header_id);    -- For bug # 9751256
   END IF;
   /* Validate Organization ID */
   l_org.organization_id := p_organization_id;
   l_result := INV_Validate.Organization(l_org);
   IF (l_result = INV_Validate.F) THEN
      FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_ORG');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   /* Validate Subinventory */
   IF (p_subinventory IS NOT NULL) THEN
      l_sub.secondary_inventory_name := p_subinventory;
      l_result := INV_Validate.subinventory(l_sub, l_org);
      IF (l_result = INV_Validate.F) THEN
	 FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_SUB');
	 FND_MSG_PUB.ADD;
	 RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   /* Validate Locator */
   IF (p_subinventory IS NOT NULL) THEN
      IF (l_sub.locator_type IN (2,3)) THEN
	 IF (p_locator_id IS NULL) THEN
	    FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_MISS_REQ_LOC');
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
	 l_locator.inventory_location_id := p_locator_id;
	 l_result := INV_Validate.validateLocator(l_locator, l_org, l_sub);
	 IF (l_result = INV_Validate.F) THEN
	    FND_MESSAGE.SET_NAME('WMS', 'WMS_CONT_INVALID_LOC');
	    FND_MSG_PUB.ADD;
	    RAISE FND_API.G_EXC_ERROR;
	 END IF;
      END IF;
   END IF;

   /* Validate the default cycle count header */
   IF (p_cycle_count_header_id IS NOT NULL) THEN     -- For bug # 9751256
      l_cycle_count_header_id := p_cycle_count_header_id;
   ELSE
      IF (l_org.default_cyc_count_header_id IS NULL) THEN
          FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_INVALID_HEADER');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          l_cycle_count_header_id := l_org.default_cyc_count_header_id;
      END IF;
   END IF;

   /* Check that unscheduled counts are allowed */
   SELECT unscheduled_count_entry
     INTO l_unscheduled_count_entry
     FROM mtl_cycle_count_headers
     WHERE cycle_count_header_id = l_cycle_count_header_id
     AND organization_id = p_organization_id;
   IF (l_unscheduled_count_entry = 2) THEN
      FND_MESSAGE.SET_NAME('INV', 'INV_CCEOI_NO_UNSCHED_COUNTS');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF (l_debug = 1) THEN
      print_debug('Finished Validations');
   END IF;

   /* End of input validation */

   -- Get a new cycle count schedule ID
   SELECT mtl_cc_schedule_requests_s.NEXTVAL
     INTO l_cycle_count_schedule_id
     FROM dual;
   IF (l_debug = 1) THEN
      print_debug('CC Schedule ID: ' || l_cycle_count_schedule_id);
   END IF;

  /* Bug 5236299 - Selecting the zero count flag for the cycle count */

  SELECT NVL(zero_count_flag,2)
    INTO l_zero_count_flag
    FROM mtl_cycle_count_headers
   WHERE cycle_count_header_id = l_cycle_count_header_id
     AND organization_id = p_organization_id;

   IF (l_debug = 1) THEN
      print_debug('Zero Count Flag: ' || l_zero_count_flag);
   END IF;

   /* End of fix for Bug 5236299 */

   /* Bug 7504490 - Checking if the p_lpn_id parameter is NULL. If it is null, call
      the cycle count generate program to create entries. If it is not null, call the
      API process_lpn_countrequest of MTL_CCEOI_ACTION_PUB to create the entry for the LPN */

   IF p_lpn_id IS NULL THEN
	   IF (l_debug = 1) THEN
	      print_debug('p_lpn_id is null');
	   END IF;

	   -- Insert a new record into MTL_CC_SCHEDULE_REQUESTS
	   IF (l_debug = 1) THEN
	      print_debug('Inserting into table MTL_CC_SCHEDULE_REQUESTS');
	   END IF;
	   INSERT INTO MTL_CC_SCHEDULE_REQUESTS
	     (cycle_count_schedule_id, last_update_date, last_updated_by,
	      creation_date, created_by, cycle_count_header_id,
	      request_source_type, zero_count_flag, schedule_date,
	      schedule_status, subinventory, locator_id,
	      inventory_item_id, revision) -- BUG #2867331   --Bug8537999 Including Revision
	     VALUES
	     (l_cycle_count_schedule_id, SYSDATE, FND_GLOBAL.USER_ID,
	      SYSDATE, FND_GLOBAL.USER_ID, l_cycle_count_header_id,
	      2, l_zero_count_flag, SYSDATE, 1, --Bug 5236299- inserting the value of l_zero_count_flag
	      p_subinventory, p_locator_id,
	      p_inventory_item_id, p_revision);    --BUG#2867331   --Bug8537999 Including Revision

	   -- We need to commit this insert first before
	   -- we can call the concurrent programs
	   COMMIT;

	   -- Call the concurrent program to generate count requests
	   IF (l_debug = 1) THEN
	      print_debug('Calling the generate count requests concurrent program');
	   END IF;
	   l_req_id := fnd_request.submit_request
	     ( application  =>  'INV',
	       program      =>  'INCACG',
	       argument1    =>  '2',
	       argument2    =>  TO_CHAR(l_cycle_count_header_id),
	       argument3    =>  TO_CHAR(p_organization_id));

	   -- Check for errors
	   IF (l_req_id <= 0 OR l_req_id IS NULL) THEN
	      IF (l_debug = 1) THEN
		 print_debug('Error in calling the generate count requests program');
	      END IF;
	      RAISE FND_API.G_EXC_ERROR;
	    ELSE
	      COMMIT;
	   END IF;

  ELSE -- Else for p_lpn_id is NULL

	   IF (l_debug = 1) THEN
	      print_debug('p_lpn_id is not null:' || p_lpn_id);
	   END IF;

	      -- Initialisize API return status to access
	   x_return_status := FND_API.G_RET_STS_SUCCESS;
           l_errorcode := 0;

	   IF (l_debug = 1) THEN
	      print_debug('Initializing the fields for the record');
	   END IF;

  	   l_interface_rec.last_update_date      := SYSDATE;
	   l_interface_rec.last_updated_by       := MTL_CCEOI_VAR_PVT.G_UserID;
	   l_interface_rec.creation_date	 := SYSDATE;
	   l_interface_rec.created_by		 := MTL_CCEOI_VAR_PVT.G_UserID;
	   l_interface_rec.process_mode		 := 1 ;
	   l_interface_rec.action_code		 := mtl_cceoi_var_pvt.G_CREATE ;
	   l_interface_rec.cycle_count_header_id := l_cycle_count_header_id ;
	   l_interface_rec.organization_id       := p_organization_id ;
	   l_interface_rec.parent_lpn_id         := p_lpn_id ;
	   l_interface_rec.inventory_item_id     := p_inventory_item_id;
	   l_interface_rec.subinventory          := p_subinventory ;
	   l_interface_rec.locator_id            := p_locator_id;
	   l_interface_rec.revision            := p_revision;

	   IF (l_debug = 1) THEN
	      print_debug('Calling the API MTL_CCEOI_ACTION_PUB');
	   END IF;

	   MTL_CCEOI_ACTION_PUB.process_lpn_countrequest
	   (    p_api_version 		=> l_api_version_int
	     ,  p_init_msg_list		=> FND_API.G_TRUE
	     ,  p_commit 		=> FND_API.G_TRUE
	     ,  p_validation_level	=> FND_API.G_VALID_LEVEL_FULL
	     ,  x_return_status 	=> x_return_status
	     ,  x_errorcode 		=> l_errorcode
	     ,  x_msg_count 		=> x_msg_count
	     ,  x_msg_data 		=> x_msg_data
             ,  p_interface_rec 	=> l_interface_rec
	     ,  x_interface_id_list 	=> l_interface_id_list
	   ) ;

	   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
		IF (l_debug = 1) THEN
	            print_debug('LPN count request error');
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
  END IF; --End of p_lpn_id condition

   -- Call the concurrent program to print
   -- the cycle count listing report
   IF (l_debug = 1) THEN
      print_debug('About to call the cycle count listing report program');
   END IF;
   l_req_id := fnd_request.submit_request
     ( application  =>  'INV',
       program      =>  'INVARCLI',
       argument1    =>  TO_CHAR(p_organization_id),
       argument2    =>  TO_CHAR(l_cycle_count_header_id),
       argument3    =>  TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS'),   --bug 5944231
       argument4    =>  TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS'),   --bug 5944231
       argument5    =>  '2',
       argument6    =>  p_subinventory,
       argument7    =>  '1',
       argument8    =>  '1',
       argument9    =>  '1');

   -- Check for errors
   IF (l_req_id <= 0 OR l_req_id IS NULL) THEN
      IF (l_debug = 1) THEN
         print_debug('Errored out when calling the cycle count listing report program');
      END IF;
      NULL;
    ELSE
      COMMIT;
   END IF;

   -- End of API body
   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1,
   -- get message info.
   FND_MSG_PUB.Count_And_Get
     (	p_count		=>	x_msg_count,
	p_data		=>	x_msg_data
	);
   IF (l_debug = 1) THEN
      print_debug('Successfully called the procedure Create_Unscheduled_Counts');
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Create_Unscheduled_Counts_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF (l_debug = 1) THEN
         print_debug('Execution error!');
      END IF;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Create_Unscheduled_Counts_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (l_debug = 1) THEN
         print_debug('Unexpected error!');
      END IF;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);
   WHEN OTHERS THEN
      ROLLBACK TO Create_Unscheduled_Counts_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF (l_debug = 1) THEN
         print_debug('Others error!');
      END IF;
      IF	FND_MSG_PUB.Check_Msg_Level
	(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg
	   (	G_PKG_NAME	,
		l_api_name
		);
      END IF;
      FND_MSG_PUB.Count_And_Get
	(	p_count		=>	x_msg_count,
		p_data		=>	x_msg_data
		);

END Create_Unscheduled_Counts;


-- End of package
END WMS_Cycle_PVT;

/
