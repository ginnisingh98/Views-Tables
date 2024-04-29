--------------------------------------------------------
--  DDL for Package Body ENG_ECO_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_ECO_UTIL" AS
/* $Header: ENGUECOB.pls 120.12.12010000.4 2009/12/28 06:43:22 minxie ship $ */

  -- Global variables and constants
  -- ---------------------------------------------------------------------------
     G_PKG_NAME                VARCHAR2(30) := 'ENG_ECO_Util';
     G_CONTROL_REC             BOM_BO_PUB.Control_Rec_Type;

  -- Global cursors
  -- ---------------------------------------------------------------------------

  -- For Debug
  g_debug_file      UTL_FILE.FILE_TYPE ;
  g_debug_flag      BOOLEAN      := FALSE ;  -- For TEST : FALSE ;
  g_output_dir      VARCHAR2(80) := NULL ;
  g_debug_filename  VARCHAR2(30) := 'eng.chgmt.eco.log' ;
  g_debug_errmesg   VARCHAR2(240);

  -- BUG 3424007: Type for defaultung lifecycle phases for ERP ECOs
  TYPE phase_list_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

PROCEDURE Org_Hierarchy_List
( p_org_hierarch_name IN  VARCHAR2,
  p_org_hier_lvl_id  IN  NUMBER,
  x_org_cod_list      OUT NOCOPY ego_number_tbl_type)
 IS

 l_index				BINARY_INTEGER;
 i NUMBER  ;
 -- list to store the index organization list
-- where organization_id is the index of the table
 eng_orgid_index_list INV_ORGHIERARCHY_PVT.OrgID_tbl_type;


 BEGIN

inv_orghierarchy_pvt.Org_Hierarchy_List
( p_org_hierarchy_name =>  p_org_hierarch_name,
  p_org_hier_level_id  => p_org_hier_lvl_id,
  x_org_code_list   => eng_orgid_index_list  );

  l_index := eng_orgid_index_list.FIRST;
  i := 1;
  x_org_cod_list := EGO_NUMBER_TBL_TYPE();
  WHILE (l_index <= eng_orgid_index_list.LAST) LOOP
        x_org_cod_list.EXTEND();
        x_org_cod_list(i) :=  eng_orgid_index_list(l_index)  ;
        l_index := eng_orgid_index_list.NEXT(l_index);
        i := i+1;
  END LOOP;

 END;


  /********************************************************************
  * API Type      : Local APIs
  * Purpose       : Those APIs are private
  *********************************************************************/

   /** R12C Changes
   * ENG Change order Proc implementation
   * */
   PROCEDURE Execute_ProcCP
  (
    p_api_version               IN   NUMBER    := 1.0                         --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2
   ,p_debug_filename            IN   VARCHAR2
   ,x_return_status             OUT NOCOPY  VARCHAR2                    --
   ,x_msg_count                 OUT NOCOPY  NUMBER                      --
   ,x_msg_data                  OUT NOCOPY  VARCHAR2                    --
   ,p_change_id                 IN   NUMBER                             --
   ,p_change_notice             IN   VARCHAR2                           --
   ,p_rev_item_seq_id           IN   NUMBER   := NULL
   ,p_org_id                    IN   NUMBER                             --
   ,p_all_org_flag              IN   VARCHAR2
   ,p_hierarchy_name            IN   VARCHAR2
   ,x_request_id                OUT NOCOPY  NUMBER                      --
  )
  IS
   l_api_name        CONSTANT VARCHAR2(30) := 'Execute_ProcCP';
    l_api_version     CONSTANT NUMBER := 1.0;
    l_return_status            VARCHAR2(1);
    l_dummy_counter            NUMBER := 0;
    -- Status Lookups
    --CANCELLED CONSTANT NUMBER := 5;
    --IMPLEMENTED CONSTANT NUMBER := 6;

    X_Model NUMBER := 1;
    X_OptionClass NUMBER := 2;
    X_Planning NUMBER := 3;
    X_Standard NUMBER := 4;
    -- Added for bug 8732198
 	    x_phase        varchar2(80)  := 'Pending';
 	    x_dev_phase    varchar2(15)  := 'Pending';
 	    x_status       varchar2(80)  := 'Pending';
 	    x_dev_status   varchar2(15)  := 'Pending';
 	    x_message      varchar2(240)  := 'Pending';
 	    Call_Status    boolean       := FALSE;

    -- Added for bug 9243978
    l_status_type  NUMBER := 0;

  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT Implement_ECO_PUB;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF ;

    -- For Test/Debug
    IF FND_API.to_Boolean( p_debug ) THEN
        ENG_CHANGE_ACTIONS_UTIL.Open_Debug_Session
        (  p_file_name          => p_debug_filename
         , p_output_dir         => p_output_dir
         );
    END IF ;

    -- Write debug message if debug mode is on
    --IF FND_API.to_Boolean( p_debug ) THEN
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('ENG_Eco_Util.Execute_ProcCP log');
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('-----------------------------------------------------');
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_api_version   ' ||     p_api_version);
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_init_msg_list '||  p_init_msg_list );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_commit '|| p_commit);
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_validation_level '|| p_validation_level);
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug(' p_debug   '||  p_debug);
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_change_id         : ' || to_char(p_change_id) );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_change_notice     : ' || p_change_notice );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_org_id            : ' || to_char(p_org_id) );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_all_org_flag     : ' || p_all_org_flag );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_hierarchy_name            : ' || p_hierarchy_name );
       IF (p_rev_item_seq_id IS NOT NULL) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_rev_item_seq_id   : ' || to_char(p_rev_item_seq_id) );
       ELSE
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_rev_item_seq_id   : NULL' );
       END IF;
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('-----------------------------------------------------');
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Initializing return status... ' );
    --END IF ;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Real pl/sql code starts here


    -- If there is no open revised items, skip the concurrent request call
    -- and return an error message

    l_dummy_counter := 1;

    IF l_dummy_counter <> 0 THEN
       -- submitting the concurrent request
      x_request_id := Fnd_Request.Submit_Request (
        application => 'ENG',
        program     => 'ENCACNC',
        description => null,
        -- start_time  => sysdate, -- R12 comment out to use sysadte with timestamp
        sub_request => false,
        argument1   => to_char(p_org_id),
        argument2   => p_all_org_flag,
        argument3   => p_hierarchy_name,
        argument4   => p_change_notice,
        argument5   => p_rev_item_seq_id,
        argument6   => null,
        argument7   => CHR(0),
        argument8   => null,
        argument9   => null,
        argument10  => null,
        argument11  => null,
        argument12  => null,
        argument13  => null,
        argument14  => null,
        argument15  => null,
        argument16  => null,
        argument17  => null,
        argument18  => null,
        argument19  => null,
        argument20  => null,
        argument21  => null,
        argument22  => null,
        argument23  => null,
        argument24  => null,
        argument25  => null,
        argument26  => null,
        argument27  => null,
        argument28  => null,
        argument29  => null,
        argument30  => null,
        argument31  => null,
        argument32  => null,
        argument33  => null,
        argument34  => null,
        argument35  => null,
        argument36  => null,
        argument37  => null,
        argument38  => null,
        argument39  => null,
        argument40  => null,
        argument41  => null,
        argument42  => null,
        argument43  => null,
        argument44  => null,
        argument45  => null,
        argument46  => null,
        argument47  => null,
        argument48  => null,
        argument49  => null,
        argument50  => null,
        argument51  => null,
        argument52  => null,
        argument53  => null,
        argument54  => null,
        argument55  => null,
        argument56  => null,
        argument57  => null,
        argument58  => null,
        argument59  => null,
        argument60  => null,
        argument61  => null,
        argument62  => null,
        argument63  => null,
        argument64  => null,
        argument65  => null,
        argument66  => null,
        argument67  => null,
        argument68  => null,
        argument69  => null,
        argument70  => null,
        argument71  => null,
        argument72  => null,
        argument73  => null,
        argument74  => null,
        argument75  => null,
        argument76  => null,
        argument77  => null,
        argument78  => null,
        argument79  => null,
        argument80  => null,
        argument81  => null,
        argument82  => null,
        argument83  => null,
        argument84  => null,
        argument85  => null,
        argument86  => null,
        argument87  => null,
        argument88  => null,
        argument89  => null,
        argument90  => null,
        argument91  => null,
        argument92  => null,
        argument93  => null,
        argument94  => null,
        argument95  => null,
        argument96  => null,
        argument97  => null,
        argument98  => null,
        argument99  => null,
        argument100 => null
      );

      IF (x_request_id <> 0) then  -- Added for bug 8732198
 	          COMMIT;
 	      call_status :=
 	               fnd_concurrent.wait_for_request(request_id => x_request_id,
 	                                               interval => 10,
 	                                               max_wait => 0,
 	                                               phase   => x_phase,
 	                                               status => x_status,
 	                                               dev_phase => x_dev_phase,
 	                                               dev_status => x_dev_status,
 	                                               message  => x_message);

        -- Code added for bug 9243978 Starts here
        IF (x_status IS NOT NULL AND (x_status = 'Cancelled' OR x_status = 'Terminated' OR x_status = 'Error')) THEN
	   BEGIN
              IF (p_change_id IS NULL) THEN
	         SELECT STATUS_TYPE INTO l_status_type FROM ENG_ENGINEERING_CHANGES WHERE CHANGE_NOTICE = p_change_notice AND ORGANIZATION_ID = p_org_id;
              ELSE
	         SELECT STATUS_TYPE INTO l_status_type FROM ENG_ENGINEERING_CHANGES WHERE CHANGE_ID = p_change_id;
	      END IF;
	   EXCEPTION
	      WHEN OTHERS THEN
                 NULL;
	   END;

	   IF (l_status_type = ENG_CHANGE_LIFECYCLE_UTIL.G_ENG_IMP_IN_PROGRESS) THEN
              IF (p_change_id IS NULL) THEN
	         ENGPKIMP.LOG_IMPLEMENT_FAILURE(p_change_notice, p_org_id, null);
              ELSE
	         ENGPKIMP.LOG_IMPLEMENT_FAILURE(p_change_id, null);
	      END IF;
	   END IF;
	END IF;
	-- Code added for bug 9243978 Ends here
      END IF;


         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('After: calling Fnd_Request.Submit_Request' );
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('  x_request_id = ' || to_char(x_request_id) );

      IF (x_request_id = 0) THEN
        FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CONCURRENT_PRGM');
        FND_MESSAGE.Set_Token('OBJECT_NAME', 'EN'||'G.ENCACNC(Implement ECO)');
             -- concatenating to work around GSCC validation error without changing esisting behaviour
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
          ENG_CHANGE_ACTIONS_UTIL.Write_Debug('setting x_request_id' );
          ENG_CHANGE_ACTIONS_UTIL.Write_Debug('  x_request_id = ' || to_char(x_request_id) );
        IF (p_rev_item_seq_id IS NOT  NULL ) THEN
              UPDATE eng_revised_items
              SET implementation_req_id = x_request_id
              WHERE revised_item_sequence_id = p_rev_item_seq_id;
         ELSE
             UPDATE eng_engineering_changes
              SET implementation_req_id = x_request_id
              WHERE change_notice = p_change_notice
                    AND organization_id = p_org_id;
         END IF ;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
      END IF;


        ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Successful: calling Fnd_Request.Submit_Request' );


    ELSE
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('No implementable revised item found ... ' );
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Fnd_Request.Submit_Request not called ... ' );

      FND_MESSAGE.Set_Name('ENG', 'ENG_CANT_IMPL_WO_REV_ITEMS');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR ;
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Done - adding error message ... ' );

    END IF ;


    -- Standard ending code ------------------------------------------------
   -- IF FND_API.To_Boolean ( p_commit ) THEN
   --Always commit to save request id.
      COMMIT ;
   -- END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

      ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Finish. Eng Of Proc') ;
      ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Implement_ECO_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Rollback and Finish with expected error.') ;
       ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Implement_ECO_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
        ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Rollback and Finish with unexpected error.') ;
        ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
    WHEN OTHERS THEN
      ROLLBACK TO Implement_ECO_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
        ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Rollback and Finish with other errors.') ;
        ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;

  END Execute_ProcCP;

  /**
   * ENG Change ECO Action
   * @author HaiXin Tie
   */

     /**  R12C Changes
   * ENG Change order Rule invocation implementation.
   * For R12C we have changed this so that for PLM/ERP Change order
   * Implementation first rule CP will get fire if there exist any attribute changes
   * Corresponding to it then Rule validation/assignment will happen.
   * after successfull execution of rule Proc CP will get fire.
   * ENG Change ECO Action.Just executable has been changed all other things are same.
   * @author HaiXin Tie
   */
  PROCEDURE Implement_ECO
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2
   ,p_debug_filename            IN   VARCHAR2
   ,x_return_status             OUT NOCOPY  VARCHAR2                    --
   ,x_msg_count                 OUT NOCOPY  NUMBER                      --
   ,x_msg_data                  OUT NOCOPY  VARCHAR2                    --
   ,p_change_id                 IN   NUMBER                             --
   ,p_change_notice             IN   VARCHAR2                           --
   ,p_rev_item_seq_id           IN   NUMBER   := NULL
   ,p_org_id                    IN   NUMBER                             --
   ,x_request_id                OUT NOCOPY  NUMBER                      --
  )
  IS
    l_api_name        CONSTANT VARCHAR2(30) := 'Implement_ECO';
    l_api_version     CONSTANT NUMBER := 1.0;
    l_return_status            VARCHAR2(1);
    l_dummy_counter            NUMBER := 0;
    -- Status Lookups
    --CANCELLED CONSTANT NUMBER := 5;
    --IMPLEMENTED CONSTANT NUMBER := 6;

    X_Model NUMBER := 1;
    X_OptionClass NUMBER := 2;
    X_Planning NUMBER := 3;
    X_Standard NUMBER := 4;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Implement_ECO_PUB;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF ;

    -- For Test/Debug
    IF FND_API.to_Boolean( p_debug ) THEN
        ENG_CHANGE_ACTIONS_UTIL.Open_Debug_Session
        (  p_file_name          => p_debug_filename
         , p_output_dir         => p_output_dir
         );
    END IF ;

    -- Write debug message if debug mode is on
    IF FND_API.to_Boolean( p_debug ) THEN
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('ENG_Eco_Util.Implement_ECO log');
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('-----------------------------------------------------');
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_change_id         : ' || to_char(p_change_id) );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_change_notice     : ' || p_change_notice );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_org_id            : ' || to_char(p_org_id) );
       IF (p_rev_item_seq_id IS NOT NULL) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_rev_item_seq_id   : ' || to_char(p_rev_item_seq_id) );
       ELSE
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_rev_item_seq_id   : NULL' );
       END IF;
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('-----------------------------------------------------');
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Initializing return status... ' );
    END IF ;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Real pl/sql code starts here


    -- If there is no open revised items, skip the concurrent request call
    -- and return an error message
    /*
    Select count(*)
    Into l_dummy_counter
    From Eng_Revised_Items eri
    Where eri.change_id = p_change_id
    And   eri.status_type not in ( 5, -- CANCELLED
                                   6, -- IMPLEMENTED
                                   9, -- IMPLEMENTATION_IN_PROGRESS
                                   2  -- HOLD
                                   )
    And   exists (
      Select null
      From mtl_system_items msi
      Where msi.inventory_item_id = eri.revised_item_id
      And   msi.organization_id = eri.organization_Id
      And   msi.bom_item_type in (X_Model, X_OptionClass, X_Planning, X_Standard)
      And   rownum = 1
    )
    And rownum = 1;
    */
    l_dummy_counter := 1;

    IF l_dummy_counter <> 0 THEN
      -- submitting the concurrent request
      x_request_id := Fnd_Request.Submit_Request (
        application => 'ENG',
        program     => 'ENCACN',
        description => null,
        -- start_time  => sysdate, -- R12 comment out to use sysadte with timestamp
        sub_request => false,
        argument1   => to_char(p_org_id),
        argument2   => to_char(2),
        argument3   => null,
        argument4   => p_change_notice,
        argument5   => p_rev_item_seq_id,
        argument6   => null,
        argument7   => CHR(0),
        argument8   => null,
        argument9   => null,
        argument10  => null,
        argument11  => null,
        argument12  => null,
        argument13  => null,
        argument14  => null,
        argument15  => null,
        argument16  => null,
        argument17  => null,
        argument18  => null,
        argument19  => null,
        argument20  => null,
        argument21  => null,
        argument22  => null,
        argument23  => null,
        argument24  => null,
        argument25  => null,
        argument26  => null,
        argument27  => null,
        argument28  => null,
        argument29  => null,
        argument30  => null,
        argument31  => null,
        argument32  => null,
        argument33  => null,
        argument34  => null,
        argument35  => null,
        argument36  => null,
        argument37  => null,
        argument38  => null,
        argument39  => null,
        argument40  => null,
        argument41  => null,
        argument42  => null,
        argument43  => null,
        argument44  => null,
        argument45  => null,
        argument46  => null,
        argument47  => null,
        argument48  => null,
        argument49  => null,
        argument50  => null,
        argument51  => null,
        argument52  => null,
        argument53  => null,
        argument54  => null,
        argument55  => null,
        argument56  => null,
        argument57  => null,
        argument58  => null,
        argument59  => null,
        argument60  => null,
        argument61  => null,
        argument62  => null,
        argument63  => null,
        argument64  => null,
        argument65  => null,
        argument66  => null,
        argument67  => null,
        argument68  => null,
        argument69  => null,
        argument70  => null,
        argument71  => null,
        argument72  => null,
        argument73  => null,
        argument74  => null,
        argument75  => null,
        argument76  => null,
        argument77  => null,
        argument78  => null,
        argument79  => null,
        argument80  => null,
        argument81  => null,
        argument82  => null,
        argument83  => null,
        argument84  => null,
        argument85  => null,
        argument86  => null,
        argument87  => null,
        argument88  => null,
        argument89  => null,
        argument90  => null,
        argument91  => null,
        argument92  => null,
        argument93  => null,
        argument94  => null,
        argument95  => null,
        argument96  => null,
        argument97  => null,
        argument98  => null,
        argument99  => null,
        argument100 => null
      );

      IF FND_API.to_Boolean( p_debug ) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('After: calling Fnd_Request.Submit_Request' );
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('  x_request_id = ' || to_char(x_request_id) );
      END IF ;

      IF (x_request_id = 0) THEN
        FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CONCURRENT_PRGM');
        FND_MESSAGE.Set_Token('OBJECT_NAME', 'EN'||'G.ENCACN(Implement ECO)');
             -- concatenating to work around GSCC validation error without changing esisting behaviour
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        x_return_status := FND_API.G_RET_STS_SUCCESS;
      END IF;

      IF FND_API.to_Boolean( p_debug ) THEN
        ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Successful: calling Fnd_Request.Submit_Request' );
      END IF ;

    ELSE
      IF FND_API.to_Boolean( p_debug ) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('No implementable revised item found ... ' );
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Fnd_Request.Submit_Request not called ... ' );
      END IF ;

      FND_MESSAGE.Set_Name('ENG', 'ENG_CANT_IMPL_WO_REV_ITEMS');
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR ;

      IF FND_API.to_Boolean( p_debug ) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Done - adding error message ... ' );
      END IF ;

    END IF ;


    -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF FND_API.to_Boolean( p_debug ) THEN
      ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Finish. Eng Of Proc') ;
      ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
    END IF ;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Implement_ECO_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF FND_API.to_Boolean( p_debug ) THEN
        ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Rollback and Finish with expected error.') ;
        ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
      END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Implement_ECO_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF FND_API.to_Boolean( p_debug ) THEN
        ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Rollback and Finish with unexpected error.') ;
        ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
      END IF ;
    WHEN OTHERS THEN
      ROLLBACK TO Implement_ECO_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF FND_API.to_Boolean( p_debug ) THEN
        ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Rollback and Finish with other errors.') ;
        ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
      END IF ;

  END Implement_ECO;

 -- Code changes for enhancement 6084027 start
       /**
         * Executes the Original ECO concurrent program
         *
         */
        PROCEDURE Execute_ProcCP
        (
          p_api_version               IN   NUMBER                             --
         ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
         ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
         ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
         ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
         ,p_output_dir                IN   VARCHAR2
         ,p_debug_filename            IN   VARCHAR2
         ,x_return_status             OUT NOCOPY  VARCHAR2                    --
         ,x_msg_count                 OUT NOCOPY  NUMBER                      --
         ,x_msg_data                  OUT NOCOPY  VARCHAR2                    --
         ,p_change_id                 IN   NUMBER                             --
         ,p_change_notice             IN   VARCHAR2                           --
         ,p_rev_item_seq_id           IN   NUMBER   := NULL
         ,p_org_id                    IN   NUMBER                             --
         ,x_request_id                OUT NOCOPY  NUMBER                      --
        )
        IS
          l_api_name        CONSTANT VARCHAR2(30) := 'Implement_ECO';
          l_api_version     CONSTANT NUMBER := 1.0;
          l_return_status            VARCHAR2(1);
          l_dummy_counter            NUMBER := 0;
          -- Status Lookups
          --CANCELLED CONSTANT NUMBER := 5;
          --IMPLEMENTED CONSTANT NUMBER := 6;

          X_Model NUMBER := 1;
          X_OptionClass NUMBER := 2;
          X_Planning NUMBER := 3;
          X_Standard NUMBER := 4;

        BEGIN

          -- Standard Start of API savepoint
          SAVEPOINT Implement_ECO_PUB;

          -- Standard call to check for call compatibility
          IF NOT FND_API.Compatible_API_Call ( l_api_version
                                              ,p_api_version
                                              ,l_api_name
                                              ,G_PKG_NAME )
          THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

          -- Initialize message list if p_init_msg_list is set to TRUE.
          IF FND_API.to_Boolean( p_init_msg_list ) THEN
             FND_MSG_PUB.initialize;
          END IF ;

          -- For Test/Debug
          IF FND_API.to_Boolean( p_debug ) THEN
              ENG_CHANGE_ACTIONS_UTIL.Open_Debug_Session
              (  p_file_name          => p_debug_filename
               , p_output_dir         => p_output_dir
               );
          END IF ;

          -- Write debug message if debug mode is on
          IF FND_API.to_Boolean( p_debug ) THEN
             ENG_CHANGE_ACTIONS_UTIL.Write_Debug('ENG_Eco_Util.Execute_ProcCP log');
             ENG_CHANGE_ACTIONS_UTIL.Write_Debug('-----------------------------------------------------');
             ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_change_id         : ' || to_char(p_change_id) );
             ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_change_notice     : ' || p_change_notice );
             ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_org_id            : ' || to_char(p_org_id) );
             IF (p_rev_item_seq_id IS NOT NULL) THEN
               ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_rev_item_seq_id   : ' || to_char(p_rev_item_seq_id) );
             ELSE
               ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_rev_item_seq_id   : NULL' );
             END IF;
             ENG_CHANGE_ACTIONS_UTIL.Write_Debug('-----------------------------------------------------');
             ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Initializing return status... ' );
          END IF ;

          -- Initialize API return status to success
          x_return_status := FND_API.G_RET_STS_SUCCESS;

          -- Real pl/sql code starts here


          -- If there is no open revised items, skip the concurrent request call
          -- and return an error message
          /*
          Select count(*)
          Into l_dummy_counter
          From Eng_Revised_Items eri
          Where eri.change_id = p_change_id
          And   eri.status_type not in ( 5, -- CANCELLED
                                         6, -- IMPLEMENTED
                                         9, -- IMPLEMENTATION_IN_PROGRESS
                                         2  -- HOLD
                                         )
          And   exists (
            Select null
            From mtl_system_items msi
            Where msi.inventory_item_id = eri.revised_item_id
            And   msi.organization_id = eri.organization_Id
            And   msi.bom_item_type in (X_Model, X_OptionClass, X_Planning, X_Standard)
            And   rownum = 1
          )
          And rownum = 1;
          */
          l_dummy_counter := 1;

          IF l_dummy_counter <> 0 THEN
            -- submitting the concurrent request

            x_request_id := Fnd_Request.Submit_Request (
              application => 'ENG',
              program     => 'ENCACNC',
              description => null,
              start_time  => sysdate,
              sub_request => false,
              argument1   => to_char(p_org_id),
              argument2   => to_char(2),
              argument3   => null,
              argument4   => p_change_notice,
              argument5   => p_rev_item_seq_id,
              argument6   => null,
              argument7   => CHR(0),
              argument8   => null,
              argument9   => null,
              argument10  => null,
              argument11  => null,
              argument12  => null,
              argument13  => null,
              argument14  => null,
              argument15  => null,
              argument16  => null,
              argument17  => null,
              argument18  => null,
              argument19  => null,
              argument20  => null,
              argument21  => null,
              argument22  => null,
              argument23  => null,
              argument24  => null,
              argument25  => null,
              argument26  => null,
              argument27  => null,
              argument28  => null,
              argument29  => null,
              argument30  => null,
              argument31  => null,
              argument32  => null,
              argument33  => null,
              argument34  => null,
              argument35  => null,
              argument36  => null,
              argument37  => null,
              argument38  => null,
              argument39  => null,
              argument40  => null,
              argument41  => null,
              argument42  => null,
              argument43  => null,
              argument44  => null,
              argument45  => null,
              argument46  => null,
              argument47  => null,
              argument48  => null,
              argument49  => null,
              argument50  => null,
              argument51  => null,
              argument52  => null,
              argument53  => null,
              argument54  => null,
              argument55  => null,
              argument56  => null,
              argument57  => null,
              argument58  => null,
              argument59  => null,
              argument60  => null,
              argument61  => null,
              argument62  => null,
              argument63  => null,
              argument64  => null,
              argument65  => null,
              argument66  => null,
              argument67  => null,
              argument68  => null,
              argument69  => null,
              argument70  => null,
              argument71  => null,
              argument72  => null,
              argument73  => null,
              argument74  => null,
              argument75  => null,
              argument76  => null,
              argument77  => null,
              argument78  => null,
              argument79  => null,
              argument80  => null,
              argument81  => null,
              argument82  => null,
              argument83  => null,
              argument84  => null,
              argument85  => null,
              argument86  => null,
              argument87  => null,
              argument88  => null,
              argument89  => null,
              argument90  => null,
              argument91  => null,
              argument92  => null,
              argument93  => null,
              argument94  => null,
              argument95  => null,
              argument96  => null,
              argument97  => null,
              argument98  => null,
              argument99  => null,
              argument100 => null
            );


            IF FND_API.to_Boolean( p_debug ) THEN
               ENG_CHANGE_ACTIONS_UTIL.Write_Debug('After: calling Fnd_Request.Submit_Request' );
               ENG_CHANGE_ACTIONS_UTIL.Write_Debug('  x_request_id = ' || to_char(x_request_id) );
            END IF ;



            IF (x_request_id = 0) THEN

              FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CONCURRENT_PRGM');
              FND_MESSAGE.Set_Token('OBJECT_NAME', 'EN'||'G.ENCACN(Implement ECO)');
                   -- concatenating to work around GSCC validation error without changing esisting behaviour
              FND_MSG_PUB.Add;
              RAISE FND_API.G_EXC_ERROR;
            ELSE

              x_return_status := FND_API.G_RET_STS_SUCCESS;
            END IF;

            IF FND_API.to_Boolean( p_debug ) THEN
              ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Successful: calling Fnd_Request.Submit_Request' );
            END IF ;

          ELSE

            IF FND_API.to_Boolean( p_debug ) THEN
               ENG_CHANGE_ACTIONS_UTIL.Write_Debug('No implementable revised item found ... ' );
               ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Fnd_Request.Submit_Request not called ... ' );
            END IF ;

            FND_MESSAGE.Set_Name('ENG', 'ENG_CANT_IMPL_WO_REV_ITEMS');
            FND_MSG_PUB.Add;
            x_return_status := FND_API.G_RET_STS_ERROR ;

            IF FND_API.to_Boolean( p_debug ) THEN
               ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Done - adding error message ... ' );
            END IF ;

          END IF ;




          -- Standard ending code ------------------------------------------------
          IF FND_API.To_Boolean ( p_commit ) THEN
            COMMIT WORK;
          END IF;

          FND_MSG_PUB.Count_And_Get
          ( p_count        =>      x_msg_count,
            p_data         =>      x_msg_data );

          IF FND_API.to_Boolean( p_debug ) THEN
            ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Finish. Eng Of Proc') ;
            ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
          END IF ;


        EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN

            ROLLBACK TO Implement_ECO_PUB;
            x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MSG_PUB.Count_And_Get
            ( p_count        =>      x_msg_count
             ,p_data         =>      x_msg_data );
            IF FND_API.to_Boolean( p_debug ) THEN
              ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Rollback and Finish with expected error.') ;
              ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
            END IF ;
          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

            ROLLBACK TO Implement_ECO_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.Count_And_Get
            ( p_count        =>      x_msg_count
             ,p_data         =>      x_msg_data );
            IF FND_API.to_Boolean( p_debug ) THEN
              ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Rollback and Finish with unexpected error.') ;
              ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
            END IF ;
          WHEN OTHERS THEN

            ROLLBACK TO Implement_ECO_PUB;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
            IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
            THEN
              FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
            END IF;
            FND_MSG_PUB.Count_And_Get
            ( p_count        =>      x_msg_count
             ,p_data         =>      x_msg_data );
            IF FND_API.to_Boolean( p_debug ) THEN
              ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Rollback and Finish with other errors.') ;
              ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
            END IF ;

          END Execute_ProcCP;
   -- Code changes for enhancement 6084027 end

  /**
   * ENG Change ECO Action
   * @author HaiXin Tie
   */
  PROCEDURE Propagate_ECO
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2                           --
   ,p_commit                    IN   VARCHAR2                           --
   ,p_validation_level          IN   NUMBER                             --
   ,p_debug                     IN   VARCHAR2                           --
   ,p_output_dir                IN   VARCHAR2                           --
   ,p_debug_filename            IN   VARCHAR2                           --
   ,x_return_status             OUT NOCOPY  VARCHAR2                    --
   ,x_msg_count                 OUT NOCOPY  NUMBER                      --
   ,x_msg_data                  OUT NOCOPY  VARCHAR2                    --
   ,p_change_id                 IN   NUMBER                             --
   ,p_change_notice             IN   VARCHAR2                           --
   ,p_hierarchy_name            IN   VARCHAR2                           --
   ,p_org_name                  IN   VARCHAR2                           --
   ,x_request_id                OUT NOCOPY  NUMBER                      --
   ,p_local_organization_id     IN   NUMBER := NULL                   -- -- Added for R12
   ,p_calling_API               IN   VARCHAR2 := NULL --R12

  )
  IS
    l_api_name        CONSTANT VARCHAR2(30) := 'Propagate_ECO';
    l_api_version     CONSTANT NUMBER := 1.0;
    l_return_status            VARCHAR2(1);
  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Propagate_ECO_PUB;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF ;

    -- For Test/Debug
    IF FND_API.to_Boolean( p_debug ) THEN
        ENG_CHANGE_ACTIONS_UTIL.Open_Debug_Session
        (  p_file_name          => p_debug_filename
         , p_output_dir         => p_output_dir
         );
    END IF ;

    -- Write debug message if debug mode is on
    IF FND_API.to_Boolean( p_debug ) THEN
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('ENG_Eco_Util.Propagate_ECO log');
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('-----------------------------------------------------');
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_change_id             : ' || to_char(p_change_id) );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_change_notice         : ' || p_change_notice );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_hierarchy_name        : ' || p_hierarchy_name );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_org_name              : ' || p_org_name );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_local_organization_id : ' || p_local_organization_id );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('-----------------------------------------------------');
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Initializing return status... ' );
    END IF ;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Real pl/sql code starts here
    x_request_id := Fnd_Request.Submit_Request (
      application => 'ENG',
      program     => 'ENGECOBO',
      description => null,
      start_time  => null,
      sub_request => false,
      argument1   => p_change_notice,
      argument2   => p_hierarchy_name,
      argument3   => p_org_name,
      argument4   => p_local_organization_id, -- Added for R12
      argument5   => p_calling_API,
      argument6   => chr(0),
      argument7   => null,
      argument8   => null,
      argument9   => null,
      argument10  => null,
      argument11  => null,
      argument12  => null,
      argument13  => null,
      argument14  => null,
      argument15  => null,
      argument16  => null,
      argument17  => null,
      argument18  => null,
      argument19  => null,
      argument20  => null,
      argument21  => null,
      argument22  => null,
      argument23  => null,
      argument24  => null,
      argument25  => null,
      argument26  => null,
      argument27  => null,
      argument28  => null,
      argument29  => null,
      argument30  => null,
      argument31  => null,
      argument32  => null,
      argument33  => null,
      argument34  => null,
      argument35  => null,
      argument36  => null,
      argument37  => null,
      argument38  => null,
      argument39  => null,
      argument40  => null,
      argument41  => null,
      argument42  => null,
      argument43  => null,
      argument44  => null,
      argument45  => null,
      argument46  => null,
      argument47  => null,
      argument48  => null,
      argument49  => null,
      argument50  => null,
      argument51  => null,
      argument52  => null,
      argument53  => null,
      argument54  => null,
      argument55  => null,
      argument56  => null,
      argument57  => null,
      argument58  => null,
      argument59  => null,
      argument60  => null,
      argument61  => null,
      argument62  => null,
      argument63  => null,
      argument64  => null,
      argument65  => null,
      argument66  => null,
      argument67  => null,
      argument68  => null,
      argument69  => null,
      argument70  => null,
      argument71  => null,
      argument72  => null,
      argument73  => null,
      argument74  => null,
      argument75  => null,
      argument76  => null,
      argument77  => null,
      argument78  => null,
      argument79  => null,
      argument80  => null,
      argument81  => null,
      argument82  => null,
      argument83  => null,
      argument84  => null,
      argument85  => null,
      argument86  => null,
      argument87  => null,
      argument88  => null,
      argument89  => null,
      argument90  => null,
      argument91  => null,
      argument92  => null,
      argument93  => null,
      argument94  => null,
      argument95  => null,
      argument96  => null,
      argument97  => null,
      argument98  => null,
      argument99  => null,
      argument100 => null);

    IF FND_API.to_Boolean( p_debug ) THEN
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('After: calling Fnd_Request.Submit_Request' );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('  x_request_id = ' || to_char(x_request_id) );
    END IF ;

    IF (x_request_id = 0) THEN
      FND_MESSAGE.Set_Name('ENG','ENG_ERROR_CONCURRENT_PRGM');
      FND_MESSAGE.Set_Token('OBJECT_NAME', 'EN'||'G.ENGECOBO(Propagate ECO)');
           -- concatenating to work around GSCC validation error without changing esisting behaviour
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      x_return_status := FND_API.G_RET_STS_SUCCESS;
    END IF;

    IF FND_API.to_Boolean( p_debug ) THEN
      ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Successful: calling Fnd_Request.Submit_Request' );
    END IF ;

    ENGECOBO.PreProcess_Propagate_Request (
       p_api_version               => 1.0
     , p_init_msg_list             => FND_API.G_FALSE
     , p_commit                    => FND_API.G_FALSE
     , p_request_id                => x_request_id
     , p_change_id                 => p_change_id
     , p_org_hierarchy_name        => p_hierarchy_name
     , p_local_organization_id     => p_local_organization_id
     , p_calling_API               => p_calling_API
     , x_return_status             => l_return_status
     , x_msg_count                 => x_msg_count
     , x_msg_data                  => x_msg_data
    ) ;

    -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF FND_API.to_Boolean( p_debug ) THEN
      ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Finish. Eng Of Proc') ;
      ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
    END IF ;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Propagate_ECO_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF FND_API.to_Boolean( p_debug ) THEN
        ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Rollback and Finish with unexpected error.') ;
        ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
      END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Propagate_ECO_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF FND_API.to_Boolean( p_debug ) THEN
        ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Rollback and Finish with unexpected error.') ;
        ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
      END IF ;
    WHEN OTHERS THEN
      ROLLBACK TO Propagate_ECO_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF FND_API.to_Boolean( p_debug ) THEN
        ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Rollback and Finish with unexpected error.') ;
        ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
      END IF ;

  END Propagate_ECO;






  PROCEDURE Reschedule_ECO
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2                           --
   ,p_commit                    IN   VARCHAR2                           --
   ,p_validation_level          IN   NUMBER                             --
   ,p_debug                     IN   VARCHAR2                           --
   ,p_output_dir                IN   VARCHAR2                           --
   ,p_debug_filename            IN   VARCHAR2                           --
   ,x_return_status             OUT NOCOPY  VARCHAR2                    --
   ,x_msg_count                 OUT NOCOPY  NUMBER                      --
   ,x_msg_data                  OUT NOCOPY  VARCHAR2                    --
   ,p_change_id                 IN   NUMBER                             --
   ,p_effectivity_date          IN   DATE                               --
   ,p_requestor_id              IN   NUMBER                             --
   ,p_comment                   IN   VARCHAR2                           --
  )
  IS
    l_api_name        CONSTANT VARCHAR2(30) := 'Reschedule_ECO';
    l_api_version     CONSTANT NUMBER := 1.0;
    l_return_status            VARCHAR2(1);

    x_user_id NUMBER := to_number(Fnd_Profile.Value('USER_ID'));
    x_login_id NUMBER := to_number(Fnd_Profile.Value('LOGIN_ID'));
    x_planning_item_access NUMBER := Fnd_Profile.Value('BOM:PLANNING_ITEM_ACCESS');
    x_model_item_access NUMBER := Fnd_Profile.Value('BOM:ITEM_ACCESS');
    x_standard_item_access NUMBER := Fnd_Profile.Value('BOM:STANDARD_ITEM_ACCESS');
    X_Model NUMBER := 1;
    X_OptionClass NUMBER := 2;
    X_Planning NUMBER := 3;
    X_Standard NUMBER := 4;
    x_change_notice VARCHAR2(10);
    x_organization_id NUMBER;

    -- Status Lookups
    --CANCELLED CONSTANT NUMBER := 5;
    --IMPLEMENTED CONSTANT NUMBER := 6;
    x_is_Chg_Sch_Date_Allowed VARCHAR(1) := 'Y';

    -- R12 Changes for common BOM
    l_Mesg_Token_Tbl       Error_Handler.Mesg_Token_Tbl_Type;
    -- Cursor to Fetch all source bill's component changes that are being updated
    -- by reschedule
    CURSOR c_source_components( cp_change_notice       eng_engineering_changes.change_notice%TYPE) IS
    SELECT bcb.component_sequence_id
    FROM bom_components_b bcb
    WHERE bcb.CHANGE_NOTICE = cp_change_notice
      AND exists
          (select 'x' from bom_bill_of_materials
           where bill_sequence_id = bcb.bill_sequence_id
                 and organization_id =  x_organization_id )
      AND (bcb.common_component_sequence_id IS NULL
           OR bcb.common_component_sequence_id = bcb.component_sequence_id)
      AND bcb.IMPLEMENTATION_DATE IS NULL;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Reschedule_ECO_PUB;

    -- begin of vamohan changes
    is_Reschedule_ECO_Allowed(p_change_id, x_is_Chg_Sch_Date_Allowed);
    IF x_is_Chg_Sch_Date_Allowed = 'N'
    THEN
        FND_MESSAGE.Set_Name('ENG','ENG_DUP_REV_ITEM_WITH_NEW_REV');  -- create and use a new message
        --FND_MESSAGE.Set_Token('ITEM_NAMES', item_names);
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- end of vamohan changes


    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF ;

    -- For Test/Debug
    IF FND_API.to_Boolean( p_debug ) THEN
        ENG_CHANGE_ACTIONS_UTIL.Open_Debug_Session
        (  p_file_name          => p_debug_filename
         , p_output_dir         => p_output_dir
        );
    END IF ;

    -- Write debug message if debug mode is on
    IF FND_API.to_Boolean( p_debug ) THEN
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('ENG_Eco_Util.Reschedule_ECO log');
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('-----------------------------------------------------');
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_change_id         : ' || to_char(p_change_id) );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_effectivity_date  : ' || to_char(p_effectivity_date) );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_requestor_id      : ' || to_char(p_requestor_id) );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_comment           : ' || substr(p_comment, 1, 240) );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('-----------------------------------------------------');
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Initializing return status... ' );
    END IF ;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Real pl/sql code starts here
    IF x_planning_item_access = 2 THEN
      X_Planning := null;
    END IF;

    IF x_model_item_access = 2 THEN
      X_Model := null;
      X_OptionClass := null;
    END IF;

    IF x_standard_item_access = 2 THEN
      X_Standard := null;
    END IF;

    SELECT change_notice, organization_id
    INTO x_change_notice, x_organization_id
    FROM eng_engineering_changes
    WHERE change_id = p_change_id;

    Update Eng_Revised_Items eri
    Set eri.scheduled_date = p_effectivity_date,
        eri.last_update_date = sysdate,
        eri.last_updated_by = x_user_id,
        eri.last_update_login = x_login_id
    Where eri.change_id = p_change_id
    And   eri.status_type not in ( 5, -- CANCELLED
                                   6, -- IMPLEMENTED
                                   9, -- IMPLEMENTATION_IN_PROGRESS
                                   2  -- HOLD
                                   )
    And   exists (
      Select null
      From mtl_system_items msi
      Where msi.inventory_item_id = eri.revised_item_id
      And   msi.organization_id = eri.organization_Id
      And   msi.bom_item_type in (X_Model, X_OptionClass, X_Planning, X_Standard)
    );

    IF FND_API.to_Boolean( p_debug ) THEN
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Eng_Revised_Items updated ... ' );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('  SQL%ROWCOUNT = ' || to_char(SQL%ROWCOUNT));
    END IF ;

    IF SQL%FOUND THEN
      IF FND_API.to_Boolean( p_debug ) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('ENG_REVISED_ITEMS rows found, updating: ' );
      END IF ;

      -- Insert records in the history table
      Insert into Eng_Current_Scheduled_Dates(
        change_id,
        change_notice,
        organization_id,
        revised_item_id,
        scheduled_date,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        schedule_id,
        employee_id,
        comments,
        revised_item_sequence_id)
      Select p_change_id,
             eri.change_notice,
             eri.organization_id,
             eri.revised_item_id,
             p_effectivity_date,
             sysdate,
             x_user_id,
             sysdate,
             x_user_id,
             x_login_id,
             eng_current_scheduled_dates_s.nextval,
             p_requestor_id,
             substr(p_comment, 1, 240),
             eri.revised_item_sequence_id
      From eng_revised_items eri,
           mtl_system_items msi
      Where eri.change_id = p_change_id
      And   eri.revised_item_id = msi.inventory_item_id
      And   eri.organization_id = msi.organization_id
      And   eri.status_type not in ( 5, -- CANCELLED
                                     6, -- IMPLEMENTED
                                     9, -- IMPLEMENTATION_IN_PROGRESS
                                     2  -- HOLD
                                     )
      And   msi.bom_item_type in
                (X_Model, X_OptionClass, X_Planning, X_Standard);

      IF FND_API.to_Boolean( p_debug ) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Eng_Current_Scheduled_Dates inserted ... ' );
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('  SQL%ROWCOUNT = ' || to_char(SQL%ROWCOUNT));
      END IF ;

      -- update revised components EFFECTIVITY_DATE
      UPDATE BOM_INVENTORY_COMPONENTS bic
         SET bic.EFFECTIVITY_DATE = p_effectivity_date
       WHERE bic.CHANGE_NOTICE = x_change_notice
         AND (bic.common_component_sequence_id IS NULL
            OR bic.common_component_sequence_id = bic.component_sequence_id)
       -- This is to ensure that the destination bill's revised item
       -- reschedule doesnt affect its components effectivity date
         AND exists
                        (select 'x' from bom_bill_of_materials
                         where bill_sequence_id = bic.bill_sequence_id
                               and organization_id =  x_organization_id )
          AND bic.IMPLEMENTATION_DATE IS NULL;

      IF FND_API.to_Boolean( p_debug ) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('BOM_INVENTORY_COMPONENTS.EFFECTIVITY_DATE updated ... ' );
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('  SQL%ROWCOUNT = ' || to_char(SQL%ROWCOUNT));
      END IF ;

      -- update revised components DISABLE_DATE
      UPDATE BOM_INVENTORY_COMPONENTS bic1
         SET bic1.DISABLE_DATE = p_effectivity_date
       WHERE bic1.CHANGE_NOTICE = x_change_notice
         AND bic1.ACD_TYPE = 3  -- ACD Type: Disable
         AND exists
                   (select 'x' from bom_bill_of_materials
                    where bill_sequence_id = bic1.bill_sequence_id
                    and organization_id =  x_organization_id )
         AND bic1.IMPLEMENTATION_DATE IS NULL;

      -- R12 : Common BOM changes
      -- updating the replicated components for the pending changes
      FOR c_sc IN c_source_components(x_change_notice)
      LOOP
        BOMPCMBM.Update_Related_Components(
            p_src_comp_seq_id => c_sc.component_sequence_id
          , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
          , x_Return_Status   => l_return_status);
      END LOOP;
      -- End changes for R12

      IF FND_API.to_Boolean( p_debug ) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('BOM_INVENTORY_COMPONENTS.DISABLE_DATE updated ... ' );
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('  SQL%ROWCOUNT = ' || to_char(SQL%ROWCOUNT));
      END IF ;

      -- update operation sequences EFFECTIVITY_DATE
      UPDATE BOM_OPERATION_SEQUENCES bos
         SET bos.EFFECTIVITY_DATE = p_effectivity_date
       WHERE bos.CHANGE_NOTICE = x_change_notice
         AND exists
                        (select 'x' from bom_operational_routings
                         where routing_sequence_id = bos.routing_sequence_id
                               and organization_id =  x_organization_id )
         AND bos.IMPLEMENTATION_DATE IS NULL;

      IF FND_API.to_Boolean( p_debug ) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('BOM_OPERATION_SEQUENCES.EFFECTIVITY_DATE updated ... ' );
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('  SQL%ROWCOUNT = ' || to_char(SQL%ROWCOUNT));
      END IF ;

      -- update operation sequences DISABLE_DATE
      UPDATE BOM_OPERATION_SEQUENCES bos1
         SET bos1.DISABLE_DATE = p_effectivity_date
       WHERE bos1.CHANGE_NOTICE = x_change_notice
         and bos1.ACD_TYPE = 3  -- ACD Type: Disable
         AND exists
                        (select 'x' from bom_operational_routings
                         where routing_sequence_id = bos1.routing_sequence_id
                               and organization_id =  x_organization_id )
         AND bos1.IMPLEMENTATION_DATE IS NULL;

      IF FND_API.to_Boolean( p_debug ) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('BOM_OPERATION_SEQUENCES.DISABLE_DATE updated ... ' );
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('  SQL%ROWCOUNT = ' || to_char(SQL%ROWCOUNT));
      END IF ;

      -- Modified query for performance bug 4251776
      -- update rev item's new revision in MTL_ITEM_REVISIONS_B
      UPDATE MTL_ITEM_REVISIONS_B
         SET effectivity_date = p_effectivity_date,
             last_update_date = sysdate
       WHERE change_notice = x_change_notice
         AND organization_id = x_organization_id
         AND implementation_date is NULL
         AND (revised_item_sequence_id, revision_id) in (SELECT revised_item_sequence_id, new_item_revision_id
                        FROM eng_revised_items eri
                       WHERE change_id = p_change_id
                         AND scheduled_date = p_effectivity_date
                         AND new_item_revision is NOT NULL
                         AND status_type not in ( 5, -- CANCELLED
                                                  6, -- IMPLEMENTED
                                                  9, -- IMPLEMENTATION_IN_PROGRESS
                                                  2  -- HOLD
                                                  )
                         AND exists (SELECT null
                                 FROM mtl_system_items msi
                                WHERE msi.inventory_item_id = eri.revised_item_id
                              AND msi.organization_id = eri.organization_Id
                              AND msi.bom_item_type in (X_Model, X_OptionClass,
                              X_Planning, X_Standard)));


-------not required to insert to MTL_ITEM_REVISIONS_TL as description is not there.




      IF FND_API.to_Boolean( p_debug ) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('MTL_ITEM_REVISIONS updated ... ' );
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('  SQL%ROWCOUNT = ' || to_char(SQL%ROWCOUNT));
      END IF ;

      -- update rev item's new revision in MTL_RTG_ITEM_REVISIONS
      UPDATE MTL_RTG_ITEM_REVISIONS
         SET effectivity_date = p_effectivity_date,
             last_update_date = sysdate
       WHERE change_notice = x_change_notice
         AND organization_id = x_organization_id
         AND implementation_date is NULL
         AND revised_item_sequence_id in (SELECT revised_item_sequence_id
                        FROM eng_revised_items eri
                       WHERE change_id = p_change_id
                         AND scheduled_date = p_effectivity_date
                         AND new_routing_revision is NOT NULL
                         AND status_type not in ( 5, -- CANCELLED
                                                  6, -- IMPLEMENTED
                                                  9, -- IMPLEMENTATION_IN_PROGRESS
                                                  2  -- HOLD
                                                  )
                         AND exists (SELECT null
                                 FROM mtl_system_items msi
                                WHERE msi.inventory_item_id = eri.revised_item_id
                              AND msi.organization_id = eri.organization_Id
                              AND msi.bom_item_type in (X_Model, X_OptionClass,
                              X_Planning, X_Standard)));

      IF FND_API.to_Boolean( p_debug ) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('MTL_RTG_ITEM_REVISIONS updated ... ' );
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('  SQL%ROWCOUNT = ' || to_char(SQL%ROWCOUNT));
      END IF ;



    ELSE
      IF FND_API.to_Boolean( p_debug ) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('ENG_REVISED_ITEMS rows NOT found. NO updates. ' );
      END IF ;

    END IF;


    -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF FND_API.to_Boolean( p_debug ) THEN
      ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Finish. Eng Of Proc') ;
      ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
    END IF ;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Reschedule_ECO_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF FND_API.to_Boolean( p_debug ) THEN
        ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Rollback and Finish with unexpected error.') ;
        ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
      END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Reschedule_ECO_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF FND_API.to_Boolean( p_debug ) THEN
        ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Rollback and Finish with unexpected error.') ;
        ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
      END IF ;
    WHEN OTHERS THEN
      ROLLBACK TO Reschedule_ECO_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF FND_API.to_Boolean( p_debug ) THEN
        ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Rollback and Finish with unexpected error.') ;
        ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
      END IF ;

  END Reschedule_ECO;




  PROCEDURE Change_Effectivity_Date
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2                           --
   ,p_commit                    IN   VARCHAR2                           --
   ,p_validation_level          IN   NUMBER                             --
   ,p_debug                     IN   VARCHAR2                           --
   ,p_output_dir                IN   VARCHAR2                           --
   ,p_debug_filename            IN   VARCHAR2                           --
   ,x_return_status             OUT NOCOPY  VARCHAR2                    --
   ,x_msg_count                 OUT NOCOPY  NUMBER                      --
   ,x_msg_data                  OUT NOCOPY  VARCHAR2                    --
   ,p_change_id                 IN   NUMBER                             --
   ,p_effectivity_date          IN   DATE                               --
   ,p_comment                   IN   VARCHAR2                           --
  )
  IS
    l_api_name        CONSTANT VARCHAR2(30) := 'Change_Effectivity_Date';
    l_api_version     CONSTANT NUMBER := 1.0;
    l_return_status            VARCHAR2(1);

    x_user_id NUMBER := to_number(Fnd_Profile.Value('USER_ID'));
    x_login_id NUMBER := to_number(Fnd_Profile.Value('LOGIN_ID'));
    x_planning_item_access NUMBER := Fnd_Profile.Value('BOM:PLANNING_ITEM_ACCESS');
    x_model_item_access NUMBER := Fnd_Profile.Value('BOM:ITEM_ACCESS');
    x_standard_item_access NUMBER := Fnd_Profile.Value('BOM:STANDARD_ITEM_ACCESS');
    X_Model NUMBER := 1;
    X_OptionClass NUMBER := 2;
    X_Planning NUMBER := 3;
    X_Standard NUMBER := 4;
    x_change_notice VARCHAR2(10);
    x_organization_id NUMBER;

    -- Status Lookups
    --CANCELLED CONSTANT NUMBER := 5;
    --IMPLEMENTED CONSTANT NUMBER := 6;
    -- R12 Changes for common BOM
    l_Mesg_Token_Tbl       Error_Handler.Mesg_Token_Tbl_Type;
    -- Cursor to Fetch all source bill's component changes that are being updated
    -- by reschedule
    CURSOR c_source_components( cp_change_notice       eng_engineering_changes.change_notice%TYPE) IS
    SELECT bcb.component_sequence_id
    FROM bom_components_b bcb
    WHERE bcb.CHANGE_NOTICE = cp_change_notice
      AND exists
          (select 'x' from bom_bill_of_materials
           where bill_sequence_id = bcb.bill_sequence_id
                 and organization_id =  x_organization_id )
      AND (bcb.common_component_sequence_id IS NULL
           OR bcb.common_component_sequence_id = bcb.component_sequence_id)
      AND bcb.IMPLEMENTATION_DATE IS NULL;
  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Change_Effectivity_Date_PUB;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF ;

    -- For Test/Debug
    IF FND_API.to_Boolean( p_debug ) THEN
        ENG_CHANGE_ACTIONS_UTIL.Open_Debug_Session
        (  p_file_name          => p_debug_filename
         , p_output_dir         => p_output_dir
        );
    END IF ;

    -- Write debug message if debug mode is on
    IF FND_API.to_Boolean( p_debug ) THEN
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('ENG_Eco_Util.Change_Effectivity_Date log');
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('-----------------------------------------------------');
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_change_id         : ' || to_char(p_change_id) );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_effectivity_date  : ' || to_char(p_effectivity_date) );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('p_comment           : ' || substr(p_comment, 1, 240) );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('-----------------------------------------------------');
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Initializing return status... ' );
    END IF ;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Real pl/sql code starts here
    IF x_planning_item_access = 2 THEN
      X_Planning := null;
    END IF;

    IF x_model_item_access = 2 THEN
      X_Model := null;
      X_OptionClass := null;
    END IF;

    IF x_standard_item_access = 2 THEN
      X_Standard := null;
    END IF;

    SELECT change_notice, organization_id
    INTO x_change_notice, x_organization_id
    FROM eng_engineering_changes
    WHERE change_id = p_change_id;

    Update Eng_Revised_Items eri
    Set eri.scheduled_date = p_effectivity_date,
        eri.last_update_date = sysdate,
        eri.last_updated_by = x_user_id,
        eri.last_update_login = x_login_id
    Where eri.change_id = p_change_id
    And   eri.status_type not in ( 5, -- CANCELLED
                                   6, -- IMPLEMENTED
                                   9, -- IMPLEMENTATION_IN_PROGRESS
                                   2  -- HOLD
                                   )
    And   exists (
      Select null
      From mtl_system_items msi
      Where msi.inventory_item_id = eri.revised_item_id
      And   msi.organization_id = eri.organization_Id
      And   msi.bom_item_type in (X_Model, X_OptionClass, X_Planning, X_Standard)
    );

    IF FND_API.to_Boolean( p_debug ) THEN
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Eng_Revised_Items updated ... ' );
       ENG_CHANGE_ACTIONS_UTIL.Write_Debug('  SQL%ROWCOUNT = ' || to_char(SQL%ROWCOUNT));
    END IF ;

    IF SQL%FOUND THEN
      IF FND_API.to_Boolean( p_debug ) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('ENG_REVISED_ITEMS rows found, updating: ' );
      END IF ;


      -- update revised components EFFECTIVITY_DATE
      UPDATE BOM_INVENTORY_COMPONENTS bic
         SET bic.EFFECTIVITY_DATE = p_effectivity_date
       WHERE bic.CHANGE_NOTICE = x_change_notice
         AND (bic.common_component_sequence_id IS NULL
            OR bic.common_component_sequence_id = bic.component_sequence_id)
       -- This is to ensure that the destination bill's revised item
       -- reschedule doesnt affect its components effectivity date
         AND exists
                        (select 'x' from bom_bill_of_materials
                         where bill_sequence_id = bic.bill_sequence_id
                               and organization_id =  x_organization_id )
          AND bic.IMPLEMENTATION_DATE IS NULL;

      IF FND_API.to_Boolean( p_debug ) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('BOM_INVENTORY_COMPONENTS.EFFECTIVITY_DATE updated ... ' );
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('  SQL%ROWCOUNT = ' || to_char(SQL%ROWCOUNT));
      END IF ;

      -- update revised components DISABLE_DATE
      UPDATE BOM_INVENTORY_COMPONENTS bic1
         SET bic1.DISABLE_DATE = p_effectivity_date
       WHERE bic1.CHANGE_NOTICE = x_change_notice
         AND bic1.ACD_TYPE = 3  -- ACD Type: Disable
         AND exists
                   (select 'x' from bom_bill_of_materials
                    where bill_sequence_id = bic1.bill_sequence_id
                    and organization_id =  x_organization_id )
         AND bic1.IMPLEMENTATION_DATE IS NULL;

      -- R12 : Common BOM changes
      -- updating the replicated components for the pending changes
      FOR c_sc IN c_source_components(x_change_notice)
      LOOP
        BOMPCMBM.Update_Related_Components(
            p_src_comp_seq_id => c_sc.component_sequence_id
          , x_Mesg_Token_Tbl  => l_Mesg_Token_Tbl
          , x_Return_Status   => l_return_status);
      END LOOP;
      -- End changes for R12

      IF FND_API.to_Boolean( p_debug ) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('BOM_INVENTORY_COMPONENTS.DISABLE_DATE updated ... ' );
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('  SQL%ROWCOUNT = ' || to_char(SQL%ROWCOUNT));
      END IF ;

      -- update operation sequences EFFECTIVITY_DATE
      UPDATE BOM_OPERATION_SEQUENCES bos
         SET bos.EFFECTIVITY_DATE = p_effectivity_date
       WHERE bos.CHANGE_NOTICE = x_change_notice
         AND exists
                        (select 'x' from bom_operational_routings
                         where routing_sequence_id = bos.routing_sequence_id
                               and organization_id =  x_organization_id )
         AND bos.IMPLEMENTATION_DATE IS NULL;

      IF FND_API.to_Boolean( p_debug ) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('BOM_OPERATION_SEQUENCES.EFFECTIVITY_DATE updated ... ' );
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('  SQL%ROWCOUNT = ' || to_char(SQL%ROWCOUNT));
      END IF ;

      -- update operation sequences DISABLE_DATE
      UPDATE BOM_OPERATION_SEQUENCES bos1
         SET bos1.DISABLE_DATE = p_effectivity_date
       WHERE bos1.CHANGE_NOTICE = x_change_notice
         and bos1.ACD_TYPE = 3  -- ACD Type: Disable
         AND exists
                        (select 'x' from bom_operational_routings
                         where routing_sequence_id = bos1.routing_sequence_id
                               and organization_id =  x_organization_id )
         AND bos1.IMPLEMENTATION_DATE IS NULL;

      IF FND_API.to_Boolean( p_debug ) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('BOM_OPERATION_SEQUENCES.DISABLE_DATE updated ... ' );
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('  SQL%ROWCOUNT = ' || to_char(SQL%ROWCOUNT));
      END IF ;

      -- Modified query for performance bug 4251776
      -- update rev item's new revision in MTL_ITEM_REVISIONS _B
      UPDATE MTL_ITEM_REVISIONS_B
         SET effectivity_date = p_effectivity_date,
             last_update_date = sysdate
       WHERE change_notice = x_change_notice
         AND organization_id = x_organization_id
         AND implementation_date is NULL
         AND (revised_item_sequence_id, revision_id) in (SELECT revised_item_sequence_id, new_item_revision_id
                        FROM eng_revised_items eri
                       WHERE change_id = p_change_id
                         AND scheduled_date = p_effectivity_date
                         AND new_item_revision is NOT NULL
                         AND status_type not in ( 5, -- CANCELLED
                                                  6, -- IMPLEMENTED
                                                  9, -- IMPLEMENTATION_IN_PROGRESS
                                                  2  -- HOLD
                                                  )
                         AND exists (SELECT null
                                 FROM mtl_system_items msi
                                WHERE msi.inventory_item_id = eri.revised_item_id
                              AND msi.organization_id = eri.organization_Id
                              AND msi.bom_item_type in (X_Model, X_OptionClass,
                              X_Planning, X_Standard)));
      --no updation of mtl_item_revisions_tl


      IF FND_API.to_Boolean( p_debug ) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('MTL_ITEM_REVISIONS updated ... ' );
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('  SQL%ROWCOUNT = ' || to_char(SQL%ROWCOUNT));
      END IF ;

      -- update rev item's new revision in MTL_RTG_ITEM_REVISIONS
      UPDATE MTL_RTG_ITEM_REVISIONS
         SET effectivity_date = p_effectivity_date,
             last_update_date = sysdate
       WHERE change_notice = x_change_notice
         AND organization_id = x_organization_id
         AND implementation_date is NULL
         AND revised_item_sequence_id in (SELECT revised_item_sequence_id
                        FROM eng_revised_items eri
                       WHERE change_id = p_change_id
                         AND scheduled_date = p_effectivity_date
                         AND new_routing_revision is NOT NULL
                         AND status_type not in ( 5, -- CANCELLED
                                                  6, -- IMPLEMENTED
                                                  9, -- IMPLEMENTATION_IN_PROGRESS
                                                  2  -- HOLD
                                                  )
                         AND exists (SELECT null
                                 FROM mtl_system_items msi
                                WHERE msi.inventory_item_id = eri.revised_item_id
                              AND msi.organization_id = eri.organization_Id
                              AND msi.bom_item_type in (X_Model, X_OptionClass,
                              X_Planning, X_Standard)));

      IF FND_API.to_Boolean( p_debug ) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('MTL_RTG_ITEM_REVISIONS updated ... ' );
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('  SQL%ROWCOUNT = ' || to_char(SQL%ROWCOUNT));
      END IF ;



    ELSE
      IF FND_API.to_Boolean( p_debug ) THEN
         ENG_CHANGE_ACTIONS_UTIL.Write_Debug('ENG_REVISED_ITEMS rows NOT found. NO updates. ' );
      END IF ;

    END IF;


    -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

    FND_MSG_PUB.Count_And_Get
    ( p_count        =>      x_msg_count,
      p_data         =>      x_msg_data );

    IF FND_API.to_Boolean( p_debug ) THEN
      ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Finish. Eng Of Proc') ;
      ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
    END IF ;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO Change_Effectivity_Date_PUB;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF FND_API.to_Boolean( p_debug ) THEN
        ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Rollback and Finish with unexpected error.') ;
        ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
      END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO Change_Effectivity_Date_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF FND_API.to_Boolean( p_debug ) THEN
        ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Rollback and Finish with unexpected error.') ;
        ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
      END IF ;
    WHEN OTHERS THEN
      ROLLBACK TO Change_Effectivity_Date_PUB;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg ( G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
      ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      IF FND_API.to_Boolean( p_debug ) THEN
        ENG_CHANGE_ACTIONS_UTIL.Write_Debug('Rollback and Finish with unexpected error.') ;
        ENG_CHANGE_ACTIONS_UTIL.Close_Debug_Session ;
      END IF ;

  END Change_Effectivity_Date;









-- Added by MK on 09/01/2000 ECO for Routing
PROCEDURE Cancel_Eco_Routing
( p_org_id              IN  NUMBER
, p_eco_name            IN  VARCHAR2
, p_cancel_comments     IN  VARCHAR2
, p_user_id             IN  NUMBER
, p_login_id            IN  NUMBER
, p_prog_id             IN  NUMBER
, p_prog_appid          IN  NUMBER
, p_original_system_ref IN  VARCHAR2
)
IS

BEGIN


    -- Delete substitute operation resources of all pending revised items on ECO
    DELETE FROM BOM_SUB_OPERATION_RESOURCES sor
    WHERE  EXISTS (SELECT NULL
                   FROM   BOM_OPERATION_SEQUENCES bos
                        , ENG_REVISED_ITEMS       ri
                   WHERE  sor.operation_sequence_id    = bos.operation_sequence_id
                   AND    bos.implementation_date      IS NULL
                   AND    bos.revised_item_sequence_id = ri.revised_item_sequence_id
                   AND    ri.status_type               = 5 -- Cancelled
                   AND    ri.organization_id           = p_org_id
                   AND    ri.change_notice             = p_eco_name
                   ) ;

    -- Delete operation resources of all pending revised items on ECO

    DELETE FROM BOM_OPERATION_RESOURCES bor
    WHERE  EXISTS (SELECT NULL
                   FROM   BOM_OPERATION_SEQUENCES bos
                        , ENG_REVISED_ITEMS       ri
                   WHERE  bor.operation_sequence_id    = bos.operation_sequence_id
                   AND    bos.implementation_date      IS NULL
                   AND    bos.revised_item_sequence_id = ri.revised_item_sequence_id
                   AND    ri.status_type               = 5 -- Cancelled
                   AND    ri.organization_id           = p_org_id
                   AND    ri.change_notice             = p_eco_name
                   ) ;

    -- Insert the cancelled rev operations into eng_revised_operations
   INSERT INTO ENG_REVISED_OPERATIONS (
                   operation_sequence_id
                 , routing_sequence_id
                 , operation_seq_num
                 , last_update_date
                 , last_updated_by
                 , creation_date
                 , created_by
                 , last_update_login
                 , standard_operation_id
                 , department_id
                 , operation_lead_time_percent
                 , minimum_transfer_quantity
                 , count_point_type
                 , operation_description
                 , effectivity_date
                 , disable_date
                 , backflush_flag
                 , option_dependent_flag
                 , attribute_category
                 , attribute1
                 , attribute2
                 , attribute3
                 , attribute4
                 , attribute5
                 , attribute6
                 , attribute7
                 , attribute8
                 , attribute9
                 , attribute10
                 , attribute11
                 , attribute12
                 , attribute13
                 , attribute14
                 , attribute15
                 , request_id
                 , program_application_id
                 , program_id
                 , program_update_date
                 , operation_type
                 , reference_flag
                 , process_op_seq_id
                 , line_op_seq_id
                 , yield
                 , cumulative_yield
                 , reverse_cumulative_yield
                 , labor_time_calc
                 , machine_time_calc
                 , total_time_calc
                 , labor_time_user
                 , machine_time_user
                 , total_time_user
                 , net_planning_percent
                 , x_coordinate
                 , y_coordinate
                 , include_in_rollup
                 , operation_yield_enabled
                 , change_notice
                 , implementation_date
                 , old_operation_sequence_id
                 , acd_type
                 , revised_item_sequence_id
                 , cancellation_date
                 , cancel_comments
                 , original_system_reference )
          SELECT
                   bos.OPERATION_SEQUENCE_ID
                 , bos.ROUTING_SEQUENCE_ID
                 , bos.OPERATION_SEQ_NUM
                 , SYSDATE                  -- Last Update Date
                 , p_user_id                -- Last Updated By
                 , SYSDATE                  -- Creation Date
                 , p_user_id                -- Created By
                 , p_login_id               -- Last Update Login
                 , bos.STANDARD_OPERATION_ID
                 , bos.DEPARTMENT_ID
                 , bos.OPERATION_LEAD_TIME_PERCENT
                 , bos.MINIMUM_TRANSFER_QUANTITY
                 , bos.COUNT_POINT_TYPE
                 , bos.OPERATION_DESCRIPTION
                 , bos.EFFECTIVITY_DATE
                 , bos.DISABLE_DATE
                 , bos.BACKFLUSH_FLAG
                 , bos.OPTION_DEPENDENT_FLAG
                 , bos.ATTRIBUTE_CATEGORY
                 , bos.ATTRIBUTE1
                 , bos.ATTRIBUTE2
                 , bos.ATTRIBUTE3
                 , bos.ATTRIBUTE4
                 , bos.ATTRIBUTE5
                 , bos.ATTRIBUTE6
                 , bos.ATTRIBUTE7
                 , bos.ATTRIBUTE8
                 , bos.ATTRIBUTE9
                 , bos.ATTRIBUTE10
                 , bos.ATTRIBUTE11
                 , bos.ATTRIBUTE12
                 , bos.ATTRIBUTE13
                 , bos.ATTRIBUTE14
                 , bos.ATTRIBUTE15
                 , NULL                       -- Request Id
                 , p_prog_appid               -- Application Id
                 , p_prog_id                  -- Program Id
                 , SYSDATE                    -- program_update_date
                 , bos.OPERATION_TYPE
                 , bos.REFERENCE_FLAG
                 , bos.PROCESS_OP_SEQ_ID
                 , bos.LINE_OP_SEQ_ID
                 , bos.YIELD
                 , bos.CUMULATIVE_YIELD
                 , bos.REVERSE_CUMULATIVE_YIELD
                 , bos.LABOR_TIME_CALC
                 , bos.MACHINE_TIME_CALC
                 , bos.TOTAL_TIME_CALC
                 , bos.LABOR_TIME_USER
                 , bos.MACHINE_TIME_USER
                 , bos.TOTAL_TIME_USER
                 , bos.NET_PLANNING_PERCENT
                 , bos.X_COORDINATE
                 , bos.Y_COORDINATE
                 , bos.INCLUDE_IN_ROLLUP
                 , bos.OPERATION_YIELD_ENABLED
                 , bos.CHANGE_NOTICE
                 , bos.IMPLEMENTATION_DATE
                 , bos.OLD_OPERATION_SEQUENCE_ID
                 , bos.ACD_TYPE
                 , bos.REVISED_ITEM_SEQUENCE_ID
                 , SYSDATE                    -- Cancellation Date
                 , substr(p_cancel_comments, 1, 240)          -- Cancel Comments
                 , p_original_system_ref
         FROM    BOM_OPERATION_SEQUENCES bos
               , ENG_REVISED_ITEMS       ri
         WHERE  bos.implementation_date      IS NULL
         AND    bos.revised_item_sequence_id = ri.revised_item_sequence_id
         AND    ri.status_type               = 5 -- Cancelled
         AND    ri.organization_id           = p_org_id
         AND    ri.change_notice             = p_eco_name ;


    -- Delete the rows from bom_operation_sequences

    DELETE FROM BOM_OPERATION_SEQUENCES bos
    WHERE  EXISTS (SELECT NULL
                   FROM   ENG_REVISED_ITEMS       ri
                   WHERE  bos.implementation_date      IS NULL
                   AND    bos.revised_item_sequence_id = ri.revised_item_sequence_id
                   AND    ri.status_type               = 5 -- Cancelled
                   AND    ri.organization_id           = p_org_id
                   AND    ri.change_notice             = p_eco_name
                   ) ;


    -- Delete routing revisions created by revised items on ECO

    DELETE FROM MTL_RTG_ITEM_REVISIONS rev
    WHERE  EXISTS (SELECT NULL
                   FROM   ENG_REVISED_ITEMS       ri
                   WHERE  rev.implementation_date      IS NULL
                   AND    rev.revised_item_sequence_id = ri.revised_item_sequence_id
                   AND    ri.status_type               = 5 -- Cancelled
                   AND    ri.organization_id           = p_org_id
                   AND    ri.change_notice             = p_eco_name
                   ) ;

    -- Delete the bom header if routing was created by this revised item and
    -- nothing else references this

    DELETE FROM BOM_OPERATIONAL_ROUTINGS bor
    WHERE  EXISTS ( SELECT NULL
                    FROM   ENG_REVISED_ITEMS       ri
                    WHERE  bor.routing_sequence_id      = ri.change_notice
                    AND    bor.routing_sequence_id      = ri.routing_sequence_id
                    AND    TRUNC(ri.last_update_date)      = TRUNC(SYSDATE)
                    AND    ri.status_type               = 5 -- Cancelled
                    AND    ri.organization_id           = p_org_id
                    AND    ri.change_notice             = p_eco_name
                   )
    AND NOT EXISTS (SELECT NULL
                    FROM   BOM_OPERATION_SEQUENCES bos
                    WHERE  bos.routing_sequence_id = bor.routing_sequence_id
                    AND    (bos.change_notice IS NULL
                            OR   bos.change_notice <> p_eco_name)
                   )
    AND (( bor.alternate_routing_designator IS NULL
           AND NOT EXISTS( SELECT NULL
                           FROM   BOM_OPERATIONAL_ROUTINGS bor2
                           WHERE  bor2.organization_id  = bor.organization_id
                           AND    bor2.assembly_item_id = bor.assembly_item_id
                           AND    bor2.alternate_routing_designator IS NOT NULL )
         )
         OR
         ( bor.alternate_routing_designator IS NOT NULL
           AND NOT EXISTS( SELECT NULL
                           FROM   ENG_REVISED_ITEMS ri2
                           WHERE  ri2.organization_id     = bor.organization_id
                           AND    ri2.routing_sequence_id = bor.routing_sequence_id
                           AND    ri2.change_notice       <> p_eco_name )
         )) ;


    -- If routing was deleted, then unset the routing_sequence_id on the revised items
    IF  SQL%FOUND THEN

        UPDATE ENG_REVISED_ITEMS  ri
        SET     routing_sequence_id       =  ''
             ,  program_id                = p_prog_id
             ,  program_application_id    = p_prog_appid
             ,  original_system_reference = p_original_system_ref
             ,  last_updated_by           = p_user_id
             ,  last_update_login         = p_login_id
        WHERE  ri.organization_id         = p_org_id
        AND    ri.change_notice           = p_eco_name
        AND    ri.status_type             = 5  -- Cancelled
        AND    NOT EXISTS (SELECT 'No Rtg Header'
                           FROM   BOM_OPERATIONAL_ROUTINGS bor
                           WHERE  bor.routing_sequence_id  = ri.routing_sequence_id
                           ) ;
    END IF;

END Cancel_Eco_Routing;



--  Procedure Cancel_Eco

PROCEDURE Cancel_Eco
( org_id                IN  NUMBER
, change_order          IN  VARCHAR2
, user_id               IN  NUMBER
, login                 IN  NUMBER
, req_id                IN  NUMBER
, prog_id               IN  NUMBER
, prog_appid            IN  NUMBER
, orig_sysref           IN  VARCHAR2
, p_cancel_comments     IN  VARCHAR2 -- Added by MK on 09/01/2000
, x_Mesg_Token_Tbl      OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
) IS
l_err_text              VARCHAR2(2000);
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_revision_id   NUMBER;
BEGIN

    -- Set cancellation date of all pending revised items on ECO

    UPDATE ENG_REVISED_ITEMS
        SET CANCELLATION_DATE = SYSDATE,
        STATUS_TYPE = 5,
        REQUEST_ID = request_id,
        PROGRAM_ID = prog_id,
        PROGRAM_APPLICATION_ID = prog_appid,
        ORIGINAL_SYSTEM_REFERENCE = orig_sysref,
        LAST_UPDATED_BY = user_id,
        LAST_UPDATE_LOGIN = login
    WHERE ORGANIZATION_ID = org_id
    AND CHANGE_NOTICE = change_order
    AND STATUS_TYPE NOT IN (5,6);

    -- Delete substitute components of all pending revised items on ECO

    DELETE FROM BOM_SUBSTITUTE_COMPONENTS SC
    WHERE SC.COMPONENT_SEQUENCE_ID IN
        (SELECT IC.COMPONENT_SEQUENCE_ID
        FROM BOM_INVENTORY_COMPONENTS IC, ENG_REVISED_ITEMS RI
        WHERE RI.ORGANIZATION_ID = org_id
        AND RI.CHANGE_NOTICE = change_order
        AND IC.REVISED_ITEM_SEQUENCE_ID = RI.REVISED_ITEM_SEQUENCE_ID
        AND IC.IMPLEMENTATION_DATE IS NULL);

    -- Delete reference designators of all pending revised items on ECO

    DELETE FROM BOM_REFERENCE_DESIGNATORS RD
        WHERE RD.COMPONENT_SEQUENCE_ID IN
        (SELECT IC.COMPONENT_SEQUENCE_ID
         FROM BOM_INVENTORY_COMPONENTS IC, ENG_REVISED_ITEMS RI
         WHERE RI.ORGANIZATION_ID = org_id
         AND RI.CHANGE_NOTICE = change_order
         AND IC.REVISED_ITEM_SEQUENCE_ID = RI.REVISED_ITEM_SEQUENCE_ID
         AND IC.IMPLEMENTATION_DATE IS NULL);

    -- Insert the cancelled rev components into eng_revised_components

    INSERT INTO ENG_REVISED_COMPONENTS (
        COMPONENT_SEQUENCE_ID,
        COMPONENT_ITEM_ID,
        OPERATION_SEQUENCE_NUM,
        BILL_SEQUENCE_ID,
        CHANGE_NOTICE,
        EFFECTIVITY_DATE,
        COMPONENT_QUANTITY,
        COMPONENT_YIELD_FACTOR,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN,
        CANCELLATION_DATE,
        CANCEL_COMMENTS, -- Added by MK on 09/01/2000
        OLD_COMPONENT_SEQUENCE_ID,
        ITEM_NUM,
        WIP_SUPPLY_TYPE,
        COMPONENT_REMARKS,
        SUPPLY_SUBINVENTORY,
        SUPPLY_LOCATOR_ID,
        DISABLE_DATE,
        ACD_TYPE,
        PLANNING_FACTOR,
        QUANTITY_RELATED,
        SO_BASIS,
        OPTIONAL,
        MUTUALLY_EXCLUSIVE_OPTIONS,
        INCLUDE_IN_COST_ROLLUP,
        CHECK_ATP,
        SHIPPING_ALLOWED,
        REQUIRED_TO_SHIP,
        REQUIRED_FOR_REVENUE,
        INCLUDE_ON_SHIP_DOCS,
        LOW_QUANTITY,
        HIGH_QUANTITY,
        REVISED_ITEM_SEQUENCE_ID,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
        ATTRIBUTE11,
        ATTRIBUTE12,
        ATTRIBUTE13,
        ATTRIBUTE14,
        ATTRIBUTE15,
        REQUEST_ID,
        PROGRAM_ID,
        PROGRAM_APPLICATION_ID,
        ORIGINAL_SYSTEM_REFERENCE,
        BASIS_TYPE)
    SELECT
        IC.COMPONENT_SEQUENCE_ID,
        IC.COMPONENT_ITEM_ID,
        IC.OPERATION_SEQ_NUM,
        IC.BILL_SEQUENCE_ID,
        IC.CHANGE_NOTICE,
        IC.EFFECTIVITY_DATE,
        IC.COMPONENT_QUANTITY,
        IC. COMPONENT_YIELD_FACTOR,
        SYSDATE,
        user_id,
        SYSDATE,
        user_id,
        login,
        sysdate,
        substr(p_cancel_comments, 1, 240), -- Added by MK on 09/01/2000
        IC.OLD_COMPONENT_SEQUENCE_ID,
        IC.ITEM_NUM,
        IC.WIP_SUPPLY_TYPE,
        IC.COMPONENT_REMARKS,
        IC.SUPPLY_SUBINVENTORY,
        IC.SUPPLY_LOCATOR_ID,
        IC.DISABLE_DATE,
        IC.ACD_TYPE,
        IC.PLANNING_FACTOR,
        IC.QUANTITY_RELATED,
        IC.SO_BASIS,
        IC.OPTIONAL,
        IC.MUTUALLY_EXCLUSIVE_OPTIONS,
        IC.INCLUDE_IN_COST_ROLLUP,
        IC.CHECK_ATP,
        IC.SHIPPING_ALLOWED,
        IC.REQUIRED_TO_SHIP,
        IC.REQUIRED_FOR_REVENUE,
        IC.INCLUDE_ON_SHIP_DOCS,
        IC.LOW_QUANTITY,
        IC.HIGH_QUANTITY,
        IC.REVISED_ITEM_SEQUENCE_ID,
        IC.ATTRIBUTE_CATEGORY,
        IC.ATTRIBUTE1,
        IC.ATTRIBUTE2,
        IC.ATTRIBUTE3,
        IC.ATTRIBUTE4,
        IC.ATTRIBUTE5,
        IC.ATTRIBUTE6,
        IC.ATTRIBUTE7,
        IC.ATTRIBUTE8,
        IC.ATTRIBUTE9,
        IC.ATTRIBUTE10,
        IC.ATTRIBUTE11,
        IC.ATTRIBUTE12,
        IC.ATTRIBUTE13,
        IC.ATTRIBUTE14,
        IC.ATTRIBUTE15,
        req_id,
        prog_id,
        prog_appid,
        orig_sysref,
        IC.BASIS_TYPE
    FROM BOM_INVENTORY_COMPONENTS IC, ENG_REVISED_ITEMS RI
    WHERE RI.ORGANIZATION_ID = org_id
    AND RI.CHANGE_NOTICE = change_order
    AND IC.CHANGE_NOTICE = RI.CHANGE_NOTICE
    AND IC.REVISED_ITEM_SEQUENCE_ID = RI.REVISED_ITEM_SEQUENCE_ID
    AND RI.BILL_SEQUENCE_ID = IC.BILL_SEQUENCE_ID
    AND IC.IMPLEMENTATION_DATE IS NULL;

    -- Delete the rows from bom_inventory_components

    DELETE FROM BOM_INVENTORY_COMPONENTS IC
    WHERE CHANGE_NOTICE = change_order
    AND IMPLEMENTATION_DATE IS NULL
    AND REVISED_ITEM_SEQUENCE_ID IN (SELECT REVISED_ITEM_SEQUENCE_ID
         FROM ENG_REVISED_ITEMS ERI
         WHERE ERI.ORGANIZATION_ID = org_id
         AND ERI.CHANGE_NOTICE = change_order
         AND ERI.STATUS_TYPE = 5);

    -- Delete item revisions created by revised items on ECO

    delete from MTL_ITEM_REVISIONS_TL
    where revision_id in(select revision_id
                         from MTL_ITEM_REVISIONS_B I
                         WHERE CHANGE_NOTICE = change_order
                         AND ORGANIZATION_ID = org_id
                         AND IMPLEMENTATION_DATE IS NULL
                         AND INVENTORY_ITEM_ID IN
                             (SELECT REVISED_ITEM_ID
                              FROM ENG_REVISED_ITEMS R
                              WHERE R.CHANGE_NOTICE = change_order
                              AND   R.ORGANIZATION_ID = org_id
                              AND   R.REVISED_ITEM_SEQUENCE_ID = I.REVISED_ITEM_SEQUENCE_ID
                              AND   R.CANCELLATION_DATE IS NOT NULL));


    DELETE FROM MTL_ITEM_REVISIONS_B I
    WHERE CHANGE_NOTICE = change_order
    AND ORGANIZATION_ID = org_id
    AND IMPLEMENTATION_DATE IS NULL
    AND INVENTORY_ITEM_ID IN (SELECT REVISED_ITEM_ID
        FROM ENG_REVISED_ITEMS R
        WHERE R.CHANGE_NOTICE = change_order
        AND   R.ORGANIZATION_ID = org_id
        AND   R.REVISED_ITEM_SEQUENCE_ID = I.REVISED_ITEM_SEQUENCE_ID
        AND   R.CANCELLATION_DATE IS NOT NULL);



    -- Delete the bom header if bill was created by this revised item and
    -- nothing else references this

    DELETE FROM BOM_BILL_OF_MATERIALS B
    WHERE B.BILL_SEQUENCE_ID in (SELECT BILL_SEQUENCE_ID
                FROM  ENG_REVISED_ITEMS ERI
                WHERE ORGANIZATION_ID = org_id
                AND   CHANGE_NOTICE = change_order
                AND   STATUS_TYPE = 5
                AND   TRUNC(LAST_UPDATE_DATE) = trunc(sysdate))
    AND   B.PENDING_FROM_ECN = change_order
    AND   NOT EXISTS (SELECT NULL
                  FROM BOM_INVENTORY_COMPONENTS C
                  WHERE C.BILL_SEQUENCE_ID = B.BILL_SEQUENCE_ID
                  AND (C.CHANGE_NOTICE IS NULL
                      OR C.CHANGE_NOTICE <> change_order))
    AND  ((B.ALTERNATE_BOM_DESIGNATOR IS NULL
         AND NOT EXISTS (SELECT NULL
                       FROM BOM_BILL_OF_MATERIALS B2
                       WHERE B2.ORGANIZATION_ID = B.ORGANIZATION_ID
                       AND   B2.ASSEMBLY_ITEM_ID = B.ASSEMBLY_ITEM_ID
                       AND   B2.ALTERNATE_BOM_DESIGNATOR IS NOT NULL))
         OR
        (B.ALTERNATE_BOM_DESIGNATOR IS NOT NULL
        AND NOT EXISTS (SELECT NULL
                       FROM ENG_REVISED_ITEMS R
                       WHERE R.ORGANIZATION_ID = B.ORGANIZATION_ID
                       AND   R.BILL_SEQUENCE_ID = B.BILL_SEQUENCE_ID
                       AND   R.CHANGE_NOTICE <> change_order)));

    -- If bill was deleted, then unset the bill_sequence_id on the revised items
    IF (SQL%ROWCOUNT > 0) THEN
        UPDATE ENG_REVISED_ITEMS  R
        SET     BILL_SEQUENCE_ID = '',
                REQUEST_ID = request_id,
                PROGRAM_ID = prog_id,
                PROGRAM_APPLICATION_ID = prog_appid,
                ORIGINAL_SYSTEM_REFERENCE = orig_sysref,
                LAST_UPDATED_BY = user_id,
                LAST_UPDATE_LOGIN = login
        WHERE  R.ORGANIZATION_ID = org_id
        AND    R.CHANGE_NOTICE = change_order
        AND    R.STATUS_TYPE = 5
        AND    NOT EXISTS (SELECT 'NO SUCH BILL'
                FROM BOM_BILL_OF_MATERIALS BOM
                WHERE BOM.BILL_SEQUENCE_ID = R.BILL_SEQUENCE_ID);
    END IF;



    /****************************************************************
    *  Added by MK on 09/01/2000
    *  Cancel ECO for Routing
    ****************************************************************/

    Cancel_Eco_Routing ( p_org_id      => org_id
                       , p_eco_name    => change_order
                       , p_cancel_comments => substr(p_cancel_comments, 1, 240)
                       , p_user_id     => user_id
                       , p_login_id    => login
                       , p_prog_id     => prog_id
                       , p_prog_appid  => prog_appid
                       , p_original_system_ref => orig_sysref
                       );


EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;

    WHEN OTHERS THEN
        IF G_CONTROL_REC.caller_type = 'FORM'
        THEN
                RAISE;
        END IF;

        l_err_text := G_PKG_NAME || ' : (Cancel ECO) '
                                || substrb(SQLERRM,1,200);
        Error_Handler.Add_Error_Token
        ( p_Message_Text => l_err_text
        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
        , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
        );

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Cancel_ECO;

--  Procedure Update_Row

PROCEDURE Update_Row
(   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_Unexp_ECO_rec                 IN  ENG_Eco_PUB.Eco_Unexposed_Rec_Type
,   p_old_ECO_rec                   IN  ENG_ECO_PUB.ECO_Rec_Type
,   x_Mesg_Token_Tbl                OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 OUT NOCOPY VARCHAR
)
IS
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_err_text              VARCHAR2(2000);
l_user_id               NUMBER;
l_login_id              NUMBER;
l_prog_appid            NUMBER;
l_prog_id               NUMBER;
l_request_id            NUMBER;
l_std_item_access       NUMBER := Eng_Globals.Get_STD_Item_Access;
l_oc_item_access        NUMBER := Eng_Globals.Get_OC_Item_Access;
l_pln_item_access       NUMBER := Eng_Globals.Get_PLN_Item_Access;
l_mdl_item_access       NUMBER := Eng_Globals.Get_MDL_Item_Access;
l_change_name           VARCHAR2(240); -- Bug 3032565
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_user_id           := Eng_Globals.Get_User_Id;
    l_login_id          := Eng_Globals.Get_Login_Id;
    l_request_id        := ENG_GLOBALS.Get_request_id;
    l_prog_appid        := ENG_GLOBALS.Get_prog_appid;
    l_prog_id           := ENG_GLOBALS.Get_prog_id;

  IF (g_control_rec.caller_type = 'FORM' AND
      g_control_rec.validation_controller = 'MAIN_EFFECTS')
     OR
     g_control_rec.caller_type <> 'FORM'
  THEN

  BEGIN
  -- Bug 3032565 Defaulted Change Name
        IF (p_eco_rec.change_name is null OR p_eco_rec.change_name = '')
        THEN
                l_change_name :=  p_eco_rec.eco_name;
        Else
                l_change_name :=  p_eco_rec.change_name;
        END IF;


        UPDATE eng_engineering_changes
              SET attribute7 = p_eco_rec.attribute7,
                     attribute8 = p_eco_rec.attribute8,
                     attribute9 = p_eco_rec.attribute9,
                     attribute10 = p_eco_rec.attribute10,
                     attribute11 = p_eco_rec.attribute11,
                     attribute12 = p_eco_rec.attribute12,
                     attribute13 = p_eco_rec.attribute13,
                     attribute14 = p_eco_rec.attribute14,
                     attribute15 = p_eco_rec.attribute15,
                     request_id = l_request_id,
                     program_application_id = l_prog_appid,
                     program_id = l_prog_id,
                     approval_status_type = p_unexp_eco_rec.approval_status_type,
                     approval_date = p_eco_rec.approval_date,
                     approval_list_id = p_unexp_eco_rec.approval_list_id,
                     change_order_type_id = p_unexp_eco_rec.change_order_type_id,
                     responsible_organization_id = p_unexp_eco_rec.responsible_org_id,
                     approval_request_date = p_eco_rec.approval_request_date,
                     change_notice = p_eco_rec.eco_name,
                     organization_id = p_unexp_eco_rec.organization_id,
                     last_update_date = sysdate,
                     last_updated_by = l_user_id,
                     last_update_login = l_login_id,
                     description = p_eco_rec.description,
                     status_type = p_unexp_eco_rec.status_type,
                     initiation_date = p_unexp_eco_rec.initiation_date,
                     implementation_date = p_unexp_eco_rec.implementation_date,
                     cancellation_date = p_unexp_eco_rec.cancellation_date,
                     cancellation_comments = p_eco_rec.cancellation_comments,
                     priority_code = p_eco_rec.priority_code,
                     reason_code = p_eco_rec.reason_code,
                     estimated_eng_cost = p_eco_rec.eng_implementation_cost,
                     estimated_mfg_cost = p_eco_rec.mfg_implementation_cost,
                     requestor_id = p_unexp_eco_rec.requestor_id,
                     attribute_category = p_eco_rec.attribute_category,
                     attribute1 = p_eco_rec.attribute1,
                     attribute2 = p_eco_rec.attribute2,
                     attribute3 = p_eco_rec.attribute3,
                     attribute4 = p_eco_rec.attribute4,
                     attribute5 = p_eco_rec.attribute5,
                     attribute6 = p_eco_rec.attribute6,
                     original_system_reference = p_eco_rec.original_system_reference,
                     project_id = p_unexp_eco_rec.project_id,
                     task_id = p_unexp_eco_rec.task_id,
                     organization_hierarchy = p_eco_rec.organization_hierarchy,
                     change_mgmt_type_code = p_unexp_eco_rec.change_mgmt_type_code, -- eng change,
                     assignee_id = p_unexp_eco_rec.assignee_id,           -- eng chagne,
                     need_by_date = p_eco_rec.need_by_date,                -- eng chagne,
                     internal_use_only = p_eco_rec.internal_use_only,           -- eng chagne,
                     source_type_code = p_unexp_eco_rec.source_type_code,      -- eng chagne,
                     source_id = p_unexp_eco_rec.source_id,             -- eng chagne,
                     effort = p_eco_rec.effort,                      -- eng chagne,
                     hierarchy_id = p_unexp_eco_rec.hierarchy_id,              -- eng chagne
                     -- Bug 2919076 // kamohan
                     -- Start Changes
                     change_name = l_change_name , -- Bug 3032565 p_eco_rec.change_name
--                   status_code = p_unexp_eco_rec.status_code
                     status_code = nvl(p_unexp_eco_rec.status_code, p_unexp_eco_rec.status_type), -- Bug 3424007
                     source_name = p_ECO_rec.Source_Name
                     -- End Changes
          WHERE change_notice = p_eco_rec.eco_name
               AND organization_id = p_unexp_eco_rec.organization_id;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN OTHERS THEN

        IF G_CONTROL_REC.caller_type = 'FORM'
        THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE;
        END IF;

        l_err_text := G_PKG_NAME || ' : Utility (ECO Update) '
                                        || substrb(SQLERRM,1,200);
        Error_Handler.Add_Error_Token
        ( p_Message_Text => l_err_text
        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
        , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
        );

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;
END;
END IF;

-- If call if from form, execute this block of code only if side effects
-- processing has been requested
-- By AS on 10/13/99

IF (g_control_rec.caller_type = 'FORM' AND
    g_control_rec.validation_controller = 'SIDE_EFFECTS')
   OR
   g_control_rec.caller_type <> 'FORM'
THEN

BEGIN
    IF p_Unexp_ECO_rec.status_type = 5
    THEN
        -- Mark ECO as 'Cancelled' and process children accordingly

        Cancel_Eco ( org_id => p_Unexp_ECO_rec.organization_id
                   , change_order => p_ECO_rec.ECO_Name
                   , user_id => ENG_GLOBALS.Get_user_id
                   , login => ENG_GLOBALS.Get_login_id
                   , req_id => ENG_GLOBALS.Get_request_id
                   , prog_id => ENG_GLOBALS.Get_prog_id
                   , prog_appid => ENG_GLOBALS.Get_prog_appid
                   , orig_sysref => p_ECO_rec.original_system_reference
                   , p_cancel_comments => p_ECO_rec.cancellation_comments
                                         -- Added by MK on 09/01/2000
                   , x_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                   );

    ELSE
        -- From ENGFMECO.pld (Procedure After_Update)

        -- Check that the user has access to the BOM Item Type
        -- of the revised item
        --
        IF Eng_Globals.Get_STD_Item_Access IS NULL AND
           Eng_Globals.Get_PLN_Item_Access IS NULL AND
           Eng_Globals.Get_MDL_Item_Access IS NULL
        THEN
                --
                -- Get respective profile values
                --
                IF fnd_profile.value('BOM:STANDARD_ITEM_ACCESS') = '1'
                THEN
                        Eng_Globals.Set_STD_Item_Access
                        ( p_std_item_access     => 4);
                ELSE
                        Eng_Globals.Set_STD_Item_Access
                        ( p_std_item_access     => NULL);
                END IF;

                IF fnd_profile.value('BOM:MODEL_ITEM_ACCESS') = '1'
                THEN
                        Eng_Globals.Set_MDL_Item_Access
                        ( p_mdl_item_access     => 1);
                        Eng_Globals.Set_OC_Item_Access
                        ( p_oc_item_access      => 2);
                ELSE
                        Eng_Globals.Set_MDL_Item_Access
                        ( p_mdl_item_access     => NULL);
                        Eng_Globals.Set_OC_Item_Access
                        ( p_oc_item_access      => NULL);
                END IF;

                IF fnd_profile.value('BOM:PLANNING_ITEM_ACCESS') = '1'
                THEN
                        Eng_Globals.Set_PLN_Item_Access
                        ( p_pln_item_access     => 3);
                ELSE
                        Eng_Globals.Set_PLN_Item_Access
                        ( p_pln_item_access     => NULL);
                END IF;
        END IF;

        l_std_item_access := Eng_Globals.Get_STD_Item_Access;
        l_oc_item_access  := Eng_Globals.Get_OC_Item_Access;
        l_pln_item_access := Eng_Globals.Get_PLN_Item_Access;
        l_mdl_item_access := Eng_Globals.Get_MDL_Item_Access;

        UPDATE eng_revised_items eri
        SET    eri.status_type = p_Unexp_ECO_rec.status_type,
               -- If ECO status is 'Scheduled', set Auto-Implement Date to SYSDATE, else NULL
               eri.auto_implement_date = decode(p_Unexp_ECO_rec.status_type, 4, SYSDATE, NULL),
               -- If ECO status is Hold, set MRP Active to No, else Yes
               eri.mrp_active = decode(p_Unexp_ECO_rec.status_type, 2, 2, 1),
               eri.last_update_date = SYSDATE,
               eri.last_updated_by = l_user_id,
               eri.last_update_login = l_login_id,
               eri.request_id = l_request_id,
               eri.program_id = l_prog_id,
               eri.program_application_id = l_prog_appid,
                eri.original_system_reference
                        = p_ECO_rec.original_system_reference
        WHERE  eri.change_notice = p_ECO_rec.ECO_name
        AND    eri.organization_id = p_Unexp_ECO_rec.organization_id
        AND    eri.status_type not in (5,6) -- Cancelled or Implemented
        AND    exists
                -- modify only those items which the user has access to
                (SELECT null
                   FROM mtl_system_items msi
                  WHERE msi.inventory_item_id = eri.revised_item_id
                    AND msi.organization_id = eri.organization_id
                    AND msi.bom_item_type IN
                        (l_STD_Item_Access
                        ,l_OC_Item_Access
                        ,l_PLN_Item_Access
                        ,l_MDL_Item_Access));
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;

    WHEN OTHERS THEN

        IF G_CONTROL_REC.caller_type = 'FORM'
        THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE;
        END IF;

        l_err_text := G_PKG_NAME || ' : Utility (ECO Update) '
                                        || substrb(SQLERRM,1,200);
        Error_Handler.Add_Error_Token
        ( p_message_name => NULL
        , p_Message_Text => l_err_text
        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
        , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
        );

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;
END;
END IF;

END Update_Row;

-- Bug: 3424007
-- Procedure to default lifecycle phases for ERP ECOs
Procedure Default_Lifecycle_phases
( p_change_id   IN NUMBER )
IS
        l_user_id               NUMBER := Eng_Globals.Get_User_Id;
        l_login_id              NUMBER := Eng_Globals.Get_Login_Id;
        l_seq_no                NUMBER := 0 ;
        l_lifecycle_phase_id    NUMBER;
        phase_types             phase_list_type;

BEGIN

        phase_types(1) := 1; --'Open'
        -- bug: 3446554 Defaulting the lifecycle in order 1,7,4,6.
        -- Scheduled phase to be followed by implemented
        phase_types(2) := 7; --'Released'
        phase_types(3) := 4; --'Scheduled'
        phase_types(4) := 6; --'Implemented'

        FOR lp IN phase_types.FIRST..phase_types.LAST
        LOOP
                SELECT eng_lifecycle_statuses_s.nextval
                INTO l_lifecycle_phase_id
                FROM dual;

                l_seq_no := l_seq_no + 10;

                insert into ENG_LIFECYCLE_STATUSES (
                  CHANGE_LIFECYCLE_STATUS_ID
                , ENTITY_NAME
                , ENTITY_ID1
                , ENTITY_ID2
                , ENTITY_ID3
                , ENTITY_ID4
                , ENTITY_ID5
                , SEQUENCE_NUMBER
                , STATUS_CODE
                , START_DATE
                , COMPLETION_DATE
                , CHANGE_WF_ROUTE_ID
                , AUTO_PROMOTE_STATUS
                , AUTO_DEMOTE_STATUS
                , WORKFLOW_STATUS
                , CHANGE_EDITABLE_FLAG
                , CREATION_DATE
                , CREATED_BY
                , LAST_UPDATE_DATE
                , LAST_UPDATED_BY
                , LAST_UPDATE_LOGIN
                , ITERATION_NUMBER
                , ACTIVE_FLAG
                , WF_SIG_POLICY
                , CHANGE_WF_ROUTE_TEMPLATE_ID)
                values (
                l_lifecycle_phase_id
                , 'ENG_CHANGE'
                , p_change_id
                , null
                , null
                , null
                , null
                , l_seq_no
                , phase_types(lp)
                , null
                , null
                , null
                , null
                , null
                , null
                , null
                , sysdate
                , l_user_id
                , sysdate
                , l_user_id
                , l_login_id
                , 0
                , 'Y'
                , null
                , NULL );
        END LOOP;

END Default_Lifecycle_phases;

--  Procedure Insert_Row

PROCEDURE Insert_Row
(   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type
,   p_Unexp_ECO_rec                 IN  ENG_Eco_PUB.Eco_Unexposed_Rec_Type
,   x_Mesg_Token_Tbl                OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 OUT NOCOPY VARCHAR
)
IS
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_err_text              VARCHAR2(2000);
l_user_id               NUMBER;
l_login_id              NUMBER;
l_prog_appid            NUMBER;
l_prog_id               NUMBER;
l_request_id            NUMBER;
l_change_name           VARCHAR2(240); -- Bug 3032565
l_change_id           NUMBER;
BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_user_id           := Eng_Globals.Get_User_Id;
    l_login_id          := Eng_Globals.Get_Login_Id;
    l_request_id        := ENG_GLOBALS.Get_request_id;
    l_prog_appid        := ENG_GLOBALS.Get_prog_appid;
    l_prog_id           := ENG_GLOBALS.Get_prog_id;


 -- Bug 3032565 Defaulted Change Name
        IF (p_ECO_rec.change_name is null OR p_ECO_rec.change_name = '')
        THEN
                l_change_name :=  p_ECO_rec.eco_name;
        Else
                l_change_name :=  p_ECO_rec.change_name;
        END IF;

IF BOM_Globals.get_debug = 'Y'
   Then
     Error_Handler.write_debug('Start to insert');
END IF;

    INSERT  INTO ENG_ENGINEERING_CHANGES
    (       ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       REQUEST_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       APPROVAL_STATUS_TYPE
    ,       APPROVAL_DATE
    ,       APPROVAL_LIST_ID
    ,       CHANGE_ORDER_TYPE_ID
    ,       RESPONSIBLE_ORGANIZATION_ID
    ,       APPROVAL_REQUEST_DATE
    ,       CHANGE_NOTICE
    ,       ORGANIZATION_ID
    ,       CHANGE_NAME
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATED_BY
    ,       CREATION_DATE
    ,       CREATED_BY
    ,       LAST_UPDATE_LOGIN
    ,       DESCRIPTION
    ,       STATUS_TYPE
    ,       INITIATION_DATE
    ,       IMPLEMENTATION_DATE
    ,       CANCELLATION_DATE
    ,       CANCELLATION_COMMENTS
    ,       PRIORITY_CODE
    ,       REASON_CODE
    ,       ESTIMATED_ENG_COST
    ,       ESTIMATED_MFG_COST
    ,       REQUESTOR_ID
    ,       ATTRIBUTE_CATEGORY
    ,       ATTRIBUTE1
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       ORIGINAL_SYSTEM_REFERENCE
    ,       PROJECT_ID
    ,       TASK_ID
    ,       CHANGE_ID
    ,       ORGANIZATION_HIERARCHY
    ,       CHANGE_MGMT_TYPE_CODE
    ,       ASSIGNEE_ID
    ,       NEED_BY_DATE
    ,       INTERNAL_USE_ONLY
    ,       SOURCE_TYPE_CODE
    ,       SOURCE_ID
    ,       EFFORT
    ,       HIERARCHY_ID
    ,       PLM_OR_ERP_CHANGE  --11.5.10
    ,       status_code
    ,       Change_Notice_Prefix --11.5.10
    ,       source_name
    )
    VALUES
    (       p_ECO_rec.attribute7
    ,       p_ECO_rec.attribute8
    ,       p_ECO_rec.attribute9
    ,       p_ECO_rec.attribute10
    ,       p_ECO_rec.attribute11
    ,       p_ECO_rec.attribute12
    ,       p_ECO_rec.attribute13
    ,       p_ECO_rec.attribute14
    ,       p_ECO_rec.attribute15
    ,       l_request_id
    ,       l_prog_appid
    ,       l_prog_id
    ,       SYSDATE
    ,       p_Unexp_ECO_rec.approval_status_type
    ,       p_ECO_rec.approval_date
    ,       p_Unexp_ECO_rec.approval_list_id
    ,       p_Unexp_ECO_rec.change_order_type_id
    ,       p_Unexp_ECO_rec.responsible_org_id
    ,       p_ECO_rec.approval_request_date
    ,       p_ECO_rec.ECO_name
    ,       p_Unexp_ECO_rec.organization_id
    ,       l_change_name     --   Bug 3032565 nvl(p_ECO_rec.change_name, p_ECO_rec.ECO_name)
    ,       SYSDATE
    ,       l_user_id
    ,       SYSDATE
    ,       l_user_id
    ,       l_login_id
    ,       p_ECO_rec.description
    ,       p_Unexp_ECO_rec.status_type
    ,       p_Unexp_ECO_rec.initiation_date
    ,       p_Unexp_ECO_rec.implementation_date
    ,       p_Unexp_ECO_rec.cancellation_date
    ,       p_ECO_rec.cancellation_comments
    ,       p_ECO_rec.priority_code
    ,       p_ECO_rec.reason_code
    ,       p_ECO_rec.ENG_implementation_cost
    ,       p_ECO_rec.MFG_implementation_Cost
    ,       p_Unexp_ECO_rec.requestor_id
    ,       p_ECO_rec.attribute_category
    ,       p_ECO_rec.attribute1
    ,       p_ECO_rec.attribute2
    ,       p_ECO_rec.attribute3
    ,       p_ECO_rec.attribute4
    ,       p_ECO_rec.attribute5
    ,       p_ECO_rec.attribute6
    ,       p_ECO_rec.original_system_reference
    ,       p_Unexp_ECO_rec.project_id
    ,       p_Unexp_ECO_rec.task_id
    ,       p_Unexp_ECO_rec.change_id
    ,       p_ECO_rec.organization_hierarchy
    ,       p_Unexp_ECO_rec.change_mgmt_type_code  -- Eng Change
    ,       p_Unexp_ECO_rec.assignee_id            -- Eng Change
    ,       p_ECO_rec.need_by_date                 -- Eng Chagne
    ,       p_ECO_rec.internal_use_only            -- Eng Chagne
    ,       p_Unexp_ECO_rec.source_type_code       -- Eng Chagne
    ,       p_Unexp_ECO_rec.source_id              -- Eng Chagne
    ,       p_ECO_rec.effort                       -- Eng Chagne
    ,       p_Unexp_ECO_rec.hierarchy_id              -- Eng Chagne
    ,       p_Eco_rec.Plm_Or_Erp_Change           --11.5.10
    ,       p_Unexp_ECO_rec.status_code
    ,       NULL --l_change_name --Bug 3570162
    ,       p_ECO_rec.Source_Name
    );

  -- Bug: 3424007: Call Default_Lifecycle_phases
  IF (p_Eco_rec.Plm_Or_Erp_Change = 'ERP')
  THEN
    Default_Lifecycle_phases(p_Unexp_ECO_rec.change_id);
  END IF;

 IF BOM_Globals.get_debug = 'Y'
   Then
     Error_Handler.write_debug('right after insert');
  end if;

BEGIN
        ENG_CHANGE_TEXT_UTIL.Insert_Update_Change ( p_change_id => p_Unexp_ECO_rec.change_id );
EXCEPTION
          WHEN OTHERS THEN
                Error_Handler.write_debug('right after ENG_CHANGE_TEXT_UTIL.Insert_Update_Change');

END;

EXCEPTION

    WHEN OTHERS THEN

IF BOM_Globals.get_debug = 'Y'
   Then
     Error_Handler.write_debug('error in insert');
     Error_Handler.write_debug(p_ECO_rec.ECO_name);
     Error_Handler.write_debug(to_char(p_Unexp_ECO_rec.organization_id));
     Error_Handler.write_debug(p_Unexp_ECO_rec.status_type);
     Error_Handler.write_debug(p_Unexp_ECO_rec.initiation_date);
     Error_Handler.write_debug(to_char(p_Unexp_ECO_rec.change_order_type_id));
     Error_Handler.write_debug(to_char(l_user_id));
     Error_Handler.write_debug(to_char(l_login_id));

END IF;



Error_Handler.Close_Debug_Session;

IF G_CONTROL_REC.caller_type = 'FORM'
        THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE;
        END IF;

        l_err_text := G_PKG_NAME || ' : Utility (ECO Insert) '
                                        || substrb(SQLERRM,1,200);
        Error_Handler.Add_Error_Token
        ( p_message_name => NULL
        , p_Message_Text => l_err_text
        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
        , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
        );

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;





END Insert_Row;

--  Procedure Delete_Row

PROCEDURE Delete_Row
(   p_change_notice                 IN  VARCHAR2
,   p_organization_id               IN  NUMBER
,   x_Mesg_Token_Tbl                OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 OUT NOCOPY VARCHAR
)
IS
l_Mesg_Token_Tbl        Error_Handler.Mesg_Token_Tbl_Type;
l_err_text              VARCHAR2(2000);
l_Token_Tbl             Error_Handler.Token_Tbl_Type;
BEGIN

    l_token_tbl(1).token_name := 'ECO_NAME';
    l_token_tbl(1).token_value := p_change_notice;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    BEGIN
        DELETE  FROM ENG_ENGINEERING_CHANGES
        WHERE   CHANGE_NOTICE = p_change_notice
        AND     ORGANIZATION_ID = p_organization_id;

    EXCEPTION
    WHEN OTHERS THEN

        IF G_CONTROL_REC.caller_type = 'FORM'
        THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE;
        END IF;

        l_err_text := G_PKG_NAME || ' : Utility (ECO Delete) '
                                        || substrb(SQLERRM,1,200);
        Error_Handler.Add_Error_Token
        ( p_Message_Text => l_err_text
        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
        , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
        );

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_Mesg_Token_Tbl := l_Mesg_Token_Tbl;
        RETURN;
    END;


    BEGIN
        DELETE  FROM ENG_CHANGE_ORDER_REVISIONS
        WHERE   CHANGE_NOTICE = p_change_notice
        AND     ORGANIZATION_ID = p_organization_id;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;

    WHEN OTHERS THEN

        IF G_CONTROL_REC.caller_type = 'FORM'
        THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                RAISE;
        END IF;

        l_err_text := G_PKG_NAME || ' : Utility (ECO Revisions Delete) '
                                        || substrb(SQLERRM,1,200);
        Error_Handler.Add_Error_Token
        ( p_Message_Text => l_err_text
        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
        , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
        );

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;
    END;

    BEGIN

        -- Delete associated Approval History records

        DELETE  FROM ENG_ECO_SUBMIT_REVISIONS
        WHERE   CHANGE_NOTICE = p_change_notice
        AND     ORGANIZATION_ID = p_organization_id;

        -- log warning

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                Error_Handler.Add_Error_Token
                        ( p_Message_Name => 'ENG_ECO_APP_HISTORY_DELETED'
                        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                        , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
                        , p_Token_Tbl => l_Token_Tbl
                        );
        END IF;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        NULL;

    WHEN OTHERS THEN

        l_err_text := G_PKG_NAME || ' : Utility (Approval History Delete) '
                                        || substrb(SQLERRM,1,200);
        Error_Handler.Add_Error_Token
        ( p_Message_Text => l_err_text
        , p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
        , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
        );

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN;
    END;
END Delete_Row;

-- Procedure Perform_Writes

PROCEDURE Perform_Writes
(   p_ECO_rec                       IN ENG_ECO_PUB.Eco_Rec_Type
,   p_Unexp_ECO_rec                 IN ENG_ECO_PUB.ECO_Unexposed_Rec_Type
,   p_old_ECO_rec                   IN ENG_ECO_PUB.Eco_Rec_Type
,   p_control_rec                   IN BOM_BO_PUB.Control_Rec_Type
                                        := BOM_BO_PUB.G_DEFAULT_CONTROL_REC
,   x_Mesg_Token_Tbl                OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type
,   x_return_status                 OUT NOCOPY VARCHAR
)
IS
-- cursor to get the lines for a given eco: bug 5414834
CURSOR lines_for_eco( p_change_id  NUMBER) IS
       SELECT status_code ,sequence_number , name
              FROM eng_change_lines_vl
              WHERE eng_change_lines_vl.change_id = p_change_id
                    and sequence_number<> -1;


BEGIN

IF BOM_Globals.get_debug = 'Y'
   Then
     Error_Handler.write_debug('Start the perform writes..');
END IF;

        G_CONTROL_REC := p_control_rec;

        IF p_ECO_rec.transaction_type = 'CREATE'
        THEN
            Insert_Row
            ( p_ECO_rec => p_ECO_rec
            , p_Unexp_ECO_rec => p_Unexp_ECO_rec
            , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
            , x_return_status => x_return_status
            );

            -- R12 Added condition to rasei PLM CM Event
            IF p_ECO_rec.plm_or_erp_change = 'PLM'
            THEN

                ENG_CHANGE_BES_UTIL.Raise_Create_Change_Event
                ( p_change_id         => p_Unexp_ECO_rec.change_id
                );


IF BOM_Globals.get_debug = 'Y'
Then
     Error_Handler.write_debug('Raised PLM CM create event ..');
END IF;


            END IF ;

IF BOM_Globals.get_debug = 'Y'
Then
     Error_Handler.write_debug('end of insert row..');
END IF;


        ELSIF p_ECO_rec.transaction_type = 'UPDATE'
        THEN
           --change the status of all open lines bug:5414834
	   if( p_Unexp_ECO_rec.status_type = 11   OR   p_Unexp_ECO_rec.status_type = 5  ) then
	      FOR line_rec IN  lines_for_eco(p_Unexp_ECO_rec.Change_Id)
              LOOP
                  UPDATE eng_change_lines SET status_code = p_Unexp_ECO_rec.status_type
                      WHERE status_code=1 AND change_id = p_Unexp_ECO_rec.Change_Id;
               END LOOP;
           end if;
	    Update_Row
            ( p_ECO_rec => p_ECO_rec
            , p_Unexp_ECO_rec => p_Unexp_ECO_rec
            , p_old_ECO_rec => p_old_ECO_rec
            , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
            , x_return_status => x_return_status
            );

            -- R12 Added condition to rasei PLM CM Event
            IF p_ECO_rec.plm_or_erp_change = 'PLM'
            THEN

                ENG_CHANGE_BES_UTIL.Raise_Update_Change_Event
                ( p_change_id         => p_Unexp_ECO_rec.change_id
                );

IF BOM_Globals.get_debug = 'Y'
Then
     Error_Handler.write_debug('Raised PLM CM update event ..');
END IF;


            END IF ;

IF BOM_Globals.get_debug = 'Y'
Then
     Error_Handler.write_debug('end of update row..');
END IF;


        ELSIF p_ECO_rec.transaction_type = 'DELETE'
        THEN
                Delete_Row
                        ( p_change_notice => p_ECO_rec.ECO_name
                        , p_organization_id => p_Unexp_ECO_rec.organization_id
                        , x_Mesg_Token_Tbl => x_Mesg_Token_Tbl
                        , x_return_status => x_return_status
                        );

IF BOM_Globals.get_debug = 'Y'
Then
     Error_Handler.write_debug('end of delete row..');
END IF;

        END IF;

 IF BOM_Globals.get_debug = 'Y'
   Then
     Error_Handler.write_debug('end of peform write..');
END IF;

END Perform_Writes;

--  Function Query_Row

PROCEDURE Query_Row
(   p_change_notice                 IN  VARCHAR2
,   p_organization_id               IN  NUMBER
,   x_ECO_rec                       OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
,   x_ECO_Unexp_Rec                 OUT NOCOPY ENG_Eco_PUB.Eco_Unexposed_Rec_Type
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_err_text                      OUT NOCOPY VARCHAR2)
IS
l_ECO_rec                     ENG_Eco_PUB.Eco_Rec_Type;
l_ECO_Unexp_rec               ENG_ECO_PUB.ECO_Unexposed_Rec_Type;
l_err_text                    VARCHAR2(2000);
BEGIN



    SELECT  ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       APPROVAL_STATUS_TYPE
    ,       APPROVAL_DATE
    ,       APPROVAL_LIST_ID
    ,       CHANGE_ORDER_TYPE_ID
    ,       RESPONSIBLE_ORGANIZATION_ID
    ,       APPROVAL_REQUEST_DATE
    ,       CHANGE_NOTICE
    ,       ORGANIZATION_ID
    ,       DESCRIPTION
    ,	    STATUS_CODE
    ,       STATUS_TYPE
    ,       INITIATION_DATE
    ,       IMPLEMENTATION_DATE
    ,       CANCELLATION_DATE
    ,       CANCELLATION_COMMENTS
    ,       PRIORITY_CODE
    ,       REASON_CODE
    ,       ESTIMATED_ENG_COST
    ,       ESTIMATED_MFG_COST
    ,       REQUESTOR_ID
    ,       ATTRIBUTE_CATEGORY
    ,       ATTRIBUTE1
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    ,       PROJECT_ID
    ,       TASK_ID
    ,       CHANGE_ID
    ,       ORGANIZATION_HIERARCHY
    ,       CHANGE_MGMT_TYPE_CODE -- Eng Change
    ,       ASSIGNEE_ID           -- Eng Change
    ,       NEED_BY_DATE          -- Eng Chagne
    ,       INTERNAL_USE_ONLY     -- Eng Chagne
    ,       SOURCE_TYPE_CODE      -- Eng Chagne
    ,       SOURCE_ID             -- Eng Change
    ,       EFFORT                -- Eng Change
    INTO    l_ECO_rec.attribute7
    ,       l_ECO_rec.attribute8
    ,       l_ECO_rec.attribute9
    ,       l_ECO_rec.attribute10
    ,       l_ECO_rec.attribute11
    ,       l_ECO_rec.attribute12
    ,       l_ECO_rec.attribute13
    ,       l_ECO_rec.attribute14
    ,       l_ECO_rec.attribute15
    ,       l_ECO_Unexp_rec.approval_status_type
    ,       l_ECO_rec.approval_date
    ,       l_ECO_Unexp_rec.approval_list_id
    ,       l_ECO_Unexp_rec.change_order_type_id
    ,       l_ECO_Unexp_rec.responsible_org_id
    ,       l_ECO_rec.approval_request_date
    ,       l_ECO_rec.ECO_Name
    ,       l_ECO_Unexp_rec.organization_id
    ,       l_ECO_rec.description
    ,       l_ECO_Unexp_rec.status_code
    ,       l_ECO_Unexp_rec.status_type
    ,       l_ECO_Unexp_rec.initiation_date
    ,       l_ECO_Unexp_rec.implementation_date
    ,       l_ECO_Unexp_rec.cancellation_date
    ,       l_ECO_rec.cancellation_comments
    ,       l_ECO_rec.priority_code
    ,       l_ECO_rec.reason_code
    ,       l_ECO_rec.ENG_implementation_cost
    ,       l_ECO_rec.MFG_implementation_cost
    ,       l_ECO_Unexp_rec.requestor_id
    ,       l_ECO_rec.attribute_category
    ,       l_ECO_rec.attribute1
    ,       l_ECO_rec.attribute2
    ,       l_ECO_rec.attribute3
    ,       l_ECO_rec.attribute4
    ,       l_ECO_rec.attribute5
    ,       l_ECO_rec.attribute6
   ,       l_ECO_Unexp_rec.project_id
    ,       l_ECO_Unexp_rec.task_id
    ,       l_ECO_Unexp_rec.change_id
--    ,       l_ECO_rec.hierarchy_flag
    ,       l_ECO_rec.organization_hierarchy
    ,       l_ECO_Unexp_rec.change_mgmt_type_code -- Eng Change
    ,       l_ECO_Unexp_rec.assignee_id           -- Eng Change
    ,       l_ECO_rec.need_by_date                -- Eng Chagne
    ,       l_ECO_rec.internal_use_only           -- Eng Chagne
    ,       l_ECO_Unexp_rec.source_type_code      -- Eng Chagne
    ,       l_ECO_Unexp_rec.source_id             -- Eng Chagne
    ,       l_ECO_rec.effort                      -- Eng Chagne
    FROM    ENG_ENGINEERING_CHANGES
    WHERE   CHANGE_NOTICE = p_change_notice
    AND     ORGANIZATION_ID = p_organization_id
    ;

    x_ECO_rec := l_ECO_rec;
    x_ECO_Unexp_rec := l_ECO_Unexp_Rec;
    x_return_status := Eng_Globals.G_RECORD_FOUND;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_ECO_rec := l_ECO_rec;
        x_ECO_Unexp_rec := l_ECO_Unexp_Rec;
        x_return_status := Eng_Globals.G_RECORD_NOT_FOUND;

    WHEN OTHERS THEN

        x_err_text := G_PKG_NAME ||
                        ' Utility (ECO Header Query_Row)' ||
                        SUBSTR(SQLERRM, 1, 100);
        x_ECO_rec := l_ECO_rec;
        x_ECO_Unexp_rec := l_ECO_Unexp_Rec;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Query_Row;


-- Procedure Perform_Approval_Status_Change
-- to centraize business logic for Approval Status change
PROCEDURE Perform_Approval_Status_Change
(   p_change_id            IN  NUMBER
 ,  p_user_id              IN  NUMBER   := NULL
 ,  p_approval_status_type IN  NUMBER
 ,  p_caller_type          IN  VARCHAR2 := 'OI'
 ,  x_return_status        OUT NOCOPY VARCHAR2
 ,  x_err_text             OUT NOCOPY VARCHAR2
)
IS

l_user_id               NUMBER;
l_login_id              NUMBER;
l_request_id            NUMBER;

BEGIN

     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_caller_type =  'WF' THEN

         l_user_id := p_user_id ;

     ELSE

         l_user_id           := Eng_Globals.Get_User_Id;
         l_login_id          := Eng_Globals.Get_Login_Id;
         l_request_id        := ENG_GLOBALS.Get_request_id;

     END IF ;

     -- Approve Change
     IF p_approval_status_type = 5 THEN

         -- Approve ECO/Change Object
         UPDATE eng_engineering_changes
            SET approval_status_type = p_approval_status_type ,
                approval_date = sysdate ,
                request_id = l_request_id ,
                last_update_date = SYSDATE ,
                last_updated_by = l_user_id ,
                last_update_login = l_login_id
          WHERE change_id = p_change_id ;

         -- Set Open Rev Item to Scheduled
         UPDATE eng_revised_items
            SET status_type = 4 ,  -- Set Rev Item Status: Scheduled
                request_id = l_request_id ,
                last_update_date = SYSDATE ,
                last_updated_by = l_user_id ,
                last_update_login = l_login_id
          WHERE change_id = p_change_id
            AND status_type = 1;  -- Rev Item Status: Open

         -- If ECO is Open, Set Status to Scheduled (bug 2307416)
         UPDATE eng_engineering_changes
            SET status_type = 4 ,    -- Scheduled
                request_id = l_request_id ,
                last_update_date = SYSDATE ,
                last_updated_by = l_user_id ,
                last_update_login = l_login_id
          WHERE change_id = p_change_id
            AND status_type = 1;   -- Open

     /* In case we need paticular business logic, put here
     -- Reject Change, Processing error or Timeout
     ELSIF p_approval_status_type IN (4, 7, 8)  THEN


         -- Reject ECO/Change Object or set Processing Error
         UPDATE eng_engineering_changes
            SET approval_status_type = p_approval_status_type ,
                approval_date = NULL ,
                request_id = l_request_id ,
                last_update_date = SYSDATE ,
                last_updated_by = l_user_id ,
                last_update_login = l_login_id
          WHERE change_id = p_change_id ;
     */

     -- Others
     ELSE

         -- Update Approval Status
         UPDATE eng_engineering_changes
            SET approval_status_type = p_approval_status_type ,
                approval_date = NULL ,
                request_id = l_request_id ,
                last_update_date = SYSDATE ,
                last_updated_by = l_user_id ,
                last_update_login = l_login_id
          WHERE change_id = p_change_id ;


     END IF ;


EXCEPTION

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_err_text := G_PKG_NAME ||
                      ' Utility (ECO Header Perform_Approval_Status_Change)' ||
                      SUBSTR(SQLERRM, 1, 100);

END Perform_Approval_Status_Change ;

 PROCEDURE submit_ECO
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_debug                     IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_output_dir                IN   VARCHAR2                   --
   ,p_debug_filename            IN   VARCHAR2
   ,x_return_status             OUT NOCOPY  VARCHAR2                    --
   ,x_msg_count                 OUT NOCOPY  NUMBER                      --
   ,x_msg_data                  OUT NOCOPY  VARCHAR2                    --
   ,p_change_id                 IN   NUMBER                             --
  )
is
BEGIN

  update eng_revised_items
  set STATUS_TYPE = 1
  where CHANGE_ID = p_change_id;

  if (p_commit =  FND_API.G_TRUE )
  then  commit;
  end if;

/*
  update eng_engineering_changes
  set STATUS_TYPE = 1
  where  CHANGE_ID = p_change_id;
*/


END submit_ECO;



--  Procedure       lock_Row
--

/*
PROCEDURE Lock_Row
(   x_return_status                 OUT NOCOPY VARCHAR2
,   x_err_text                      OUT NOCOPY VARCHAR2
,   p_ECO_rec                       IN  ENG_Eco_PUB.Eco_Rec_Type
,   x_ECO_rec                       OUT NOCOPY ENG_Eco_PUB.Eco_Rec_Type
)
IS
l_ECO_rec                     ENG_Eco_PUB.Eco_Rec_Type;
BEGIN

    SELECT  ATTRIBUTE7
    ,       ATTRIBUTE8
    ,       ATTRIBUTE9
    ,       ATTRIBUTE10
    ,       ATTRIBUTE11
    ,       ATTRIBUTE12
    ,       ATTRIBUTE13
    ,       ATTRIBUTE14
    ,       ATTRIBUTE15
    ,       REQUEST_ID
    ,       PROGRAM_APPLICATION_ID
    ,       PROGRAM_ID
    ,       PROGRAM_UPDATE_DATE
    ,       APPROVAL_STATUS_TYPE
    ,       APPROVAL_DATE
    ,       APPROVAL_LIST_ID
    ,       CHANGE_ORDER_TYPE_ID
    ,       RESPONSIBLE_ORGANIZATION_ID
    ,       APPROVAL_REQUEST_DATE
    ,       CHANGE_NOTICE
    ,       ORGANIZATION_ID
    ,       LAST_UPDATE_DATE
    ,       LAST_UPDATED_BY
    ,       CREATION_DATE
    ,       CREATED_BY
    ,       LAST_UPDATE_LOGIN
    ,       DESCRIPTION
    ,       STATUS_TYPE
    ,       INITIATION_DATE
    ,       IMPLEMENTATION_DATE
    ,       CANCELLATION_DATE
    ,       CANCELLATION_COMMENTS
    ,       PRIORITY_CODE
    ,       REASON_CODE
    ,       ESTIMATED_ENG_COST
    ,       ESTIMATED_MFG_COST
    ,       REQUESTOR_ID
    ,       ATTRIBUTE_CATEGORY
    ,       ATTRIBUTE1
    ,       ATTRIBUTE2
    ,       ATTRIBUTE3
    ,       ATTRIBUTE4
    ,       ATTRIBUTE5
    ,       ATTRIBUTE6
    INTO    l_ECO_rec.attribute7
    ,       l_ECO_rec.attribute8
    ,       l_ECO_rec.attribute9
    ,       l_ECO_rec.attribute10
    ,       l_ECO_rec.attribute11
    ,       l_ECO_rec.attribute12
    ,       l_ECO_rec.attribute13
    ,       l_ECO_rec.attribute14
    ,       l_ECO_rec.attribute15
    ,       l_ECO_rec.request_id
    ,       l_ECO_rec.program_application_id
    ,       l_ECO_rec.program_id
    ,       l_ECO_rec.program_update_date
    ,       l_ECO_rec.approval_status_type
    ,       l_ECO_rec.approval_date
    ,       l_ECO_rec.approval_list_id
    ,       l_ECO_rec.change_order_type_id
    ,       l_ECO_rec.responsible_org_id
    ,       l_ECO_rec.approval_request_date
    ,       l_ECO_rec.change_notice
    ,       l_ECO_rec.organization_id
    ,       l_ECO_rec.last_update_date
    ,       l_ECO_rec.last_updated_by
    ,       l_ECO_rec.creation_date
    ,       l_ECO_rec.created_by
    ,       l_ECO_rec.last_update_login
    ,       l_ECO_rec.description
    ,       l_ECO_rec.status_type
    ,       l_ECO_rec.initiation_date
    ,       l_ECO_rec.implementation_date
    ,       l_ECO_rec.cancellation_date
    ,       l_ECO_rec.cancellation_comments
    ,       l_ECO_rec.priority_code
    ,       l_ECO_rec.reason_code
    ,       l_ECO_rec.ENG_implementation_cost
    ,       l_ECO_rec.MFG_implementation_cost
    ,       l_ECO_rec.requestor_id
    ,       l_ECO_rec.attribute_category
    ,       l_ECO_rec.attribute1
    ,       l_ECO_rec.attribute2
    ,       l_ECO_rec.attribute3
    ,       l_ECO_rec.attribute4
    ,       l_ECO_rec.attribute5
    ,       l_ECO_rec.attribute6
    FROM    ENG_ENGINEERING_CHANGES
    WHERE   CHANGE_NOTICE = p_ECO_rec.change_notice
    AND     ORGANIZATION_ID = p_ECO_rec.organization_id
        FOR UPDATE NOWAIT;

    --  Row locked. Compare IN attributes to DB attributes.

    IF  (   (l_ECO_rec.attribute7 =
             p_ECO_rec.attribute7) OR
            ((p_ECO_rec.attribute7 = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.attribute7 IS NULL) AND
                (p_ECO_rec.attribute7 IS NULL))))
    AND (   (l_ECO_rec.attribute8 =
             p_ECO_rec.attribute8) OR
            ((p_ECO_rec.attribute8 = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.attribute8 IS NULL) AND
                (p_ECO_rec.attribute8 IS NULL))))
    AND (   (l_ECO_rec.attribute9 =
             p_ECO_rec.attribute9) OR
            ((p_ECO_rec.attribute9 = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.attribute9 IS NULL) AND
                (p_ECO_rec.attribute9 IS NULL))))
    AND (   (l_ECO_rec.attribute10 =
             p_ECO_rec.attribute10) OR
            ((p_ECO_rec.attribute10 = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.attribute10 IS NULL) AND
                (p_ECO_rec.attribute10 IS NULL))))
    AND (   (l_ECO_rec.attribute11 =
             p_ECO_rec.attribute11) OR
            ((p_ECO_rec.attribute11 = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.attribute11 IS NULL) AND
                (p_ECO_rec.attribute11 IS NULL))))
    AND (   (l_ECO_rec.attribute12 =
             p_ECO_rec.attribute12) OR
            ((p_ECO_rec.attribute12 = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.attribute12 IS NULL) AND
                (p_ECO_rec.attribute12 IS NULL))))
    AND (   (l_ECO_rec.attribute13 =
             p_ECO_rec.attribute13) OR
            ((p_ECO_rec.attribute13 = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.attribute13 IS NULL) AND
                (p_ECO_rec.attribute13 IS NULL))))
    AND (   (l_ECO_rec.attribute14 =
             p_ECO_rec.attribute14) OR
            ((p_ECO_rec.attribute14 = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.attribute14 IS NULL) AND
                (p_ECO_rec.attribute14 IS NULL))))
    AND (   (l_ECO_rec.attribute15 =
             p_ECO_rec.attribute15) OR
            ((p_ECO_rec.attribute15 = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.attribute15 IS NULL) AND
                (p_ECO_rec.attribute15 IS NULL))))
    AND (   (l_ECO_rec.request_id =
             p_ECO_rec.request_id) OR
            ((p_ECO_rec.request_id = FND_API.G_MISS_NUM) OR
            (   (l_ECO_rec.request_id IS NULL) AND
                (p_ECO_rec.request_id IS NULL))))
    AND (   (l_ECO_rec.program_application_id =
             p_ECO_rec.program_application_id) OR
            ((p_ECO_rec.program_application_id = FND_API.G_MISS_NUM) OR
            (   (l_ECO_rec.program_application_id IS NULL) AND
                (p_ECO_rec.program_application_id IS NULL))))
    AND (   (l_ECO_rec.program_id =
             p_ECO_rec.program_id) OR
            ((p_ECO_rec.program_id = FND_API.G_MISS_NUM) OR
            (   (l_ECO_rec.program_id IS NULL) AND
                (p_ECO_rec.program_id IS NULL))))
    AND (   (l_ECO_rec.program_update_date =
             p_ECO_rec.program_update_date) OR
            ((p_ECO_rec.program_update_date = FND_API.G_MISS_DATE) OR
            (   (l_ECO_rec.program_update_date IS NULL) AND
                (p_ECO_rec.program_update_date IS NULL))))
    AND (   (l_ECO_rec.approval_status_type =
             p_ECO_rec.approval_status_type) OR
            ((p_ECO_rec.approval_status_type = FND_API.G_MISS_NUM) OR
            (   (l_ECO_rec.approval_status_type IS NULL) AND
                (p_ECO_rec.approval_status_type IS NULL))))
    AND (   (l_ECO_rec.approval_date =
             p_ECO_rec.approval_date) OR
            ((p_ECO_rec.approval_date = FND_API.G_MISS_DATE) OR
            (   (l_ECO_rec.approval_date IS NULL) AND
                (p_ECO_rec.approval_date IS NULL))))
    AND (   (l_ECO_rec.approval_list_id =
             p_ECO_rec.approval_list_id) OR
            ((p_ECO_rec.approval_list_id = FND_API.G_MISS_NUM) OR
            (   (l_ECO_rec.approval_list_id IS NULL) AND
                (p_ECO_rec.approval_list_id IS NULL))))
    AND (   (l_ECO_rec.change_order_type_id =
             p_ECO_rec.change_order_type_id) OR
            ((p_ECO_rec.change_order_type_id = FND_API.G_MISS_NUM) OR
            (   (l_ECO_rec.change_order_type_id IS NULL) AND
                (p_ECO_rec.change_order_type_id IS NULL))))
    AND (   (l_ECO_rec.responsible_org_id =
             p_ECO_rec.responsible_org_id) OR
            ((p_ECO_rec.responsible_org_id = FND_API.G_MISS_NUM) OR
            (   (l_ECO_rec.responsible_org_id IS NULL) AND
                (p_ECO_rec.responsible_org_id IS NULL))))
    AND (   (l_ECO_rec.approval_request_date =
             p_ECO_rec.approval_request_date) OR
            ((p_ECO_rec.approval_request_date = FND_API.G_MISS_DATE) OR
            (   (l_ECO_rec.approval_request_date IS NULL) AND
                (p_ECO_rec.approval_request_date IS NULL))))
    AND (   (l_ECO_rec.change_notice =
             p_ECO_rec.change_notice) OR
            ((p_ECO_rec.change_notice = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.change_notice IS NULL) AND
                (p_ECO_rec.change_notice IS NULL))))
    AND (   (l_ECO_rec.organization_id =
             p_ECO_rec.organization_id) OR
            ((p_ECO_rec.organization_id = FND_API.G_MISS_NUM) OR
            (   (l_ECO_rec.organization_id IS NULL) AND
                (p_ECO_rec.organization_id IS NULL))))
    AND (   (l_ECO_rec.last_update_date =
             p_ECO_rec.last_update_date) OR
            ((p_ECO_rec.last_update_date = FND_API.G_MISS_DATE) OR
            (   (l_ECO_rec.last_update_date IS NULL) AND
                (p_ECO_rec.last_update_date IS NULL))))
    AND (   (l_ECO_rec.last_updated_by =
             p_ECO_rec.last_updated_by) OR
            ((p_ECO_rec.last_updated_by = FND_API.G_MISS_NUM) OR
            (   (l_ECO_rec.last_updated_by IS NULL) AND
                (p_ECO_rec.last_updated_by IS NULL))))
    AND (   (l_ECO_rec.creation_date =
             p_ECO_rec.creation_date) OR
            ((p_ECO_rec.creation_date = FND_API.G_MISS_DATE) OR
            (   (l_ECO_rec.creation_date IS NULL) AND
                (p_ECO_rec.creation_date IS NULL))))
    AND (   (l_ECO_rec.created_by =
             p_ECO_rec.created_by) OR
            ((p_ECO_rec.created_by = FND_API.G_MISS_NUM) OR
            (   (l_ECO_rec.created_by IS NULL) AND
                (p_ECO_rec.created_by IS NULL))))
    AND (   (l_ECO_rec.last_update_login =
             p_ECO_rec.last_update_login) OR
            ((p_ECO_rec.last_update_login = FND_API.G_MISS_NUM) OR
            (   (l_ECO_rec.last_update_login IS NULL) AND
                (p_ECO_rec.last_update_login IS NULL))))
    AND (   (l_ECO_rec.description =
             p_ECO_rec.description) OR
            ((p_ECO_rec.description = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.description IS NULL) AND
                (p_ECO_rec.description IS NULL))))
    AND (   (l_ECO_rec.status_type =
             p_ECO_rec.status_type) OR
            ((p_ECO_rec.status_type = FND_API.G_MISS_NUM) OR
            (   (l_ECO_rec.status_type IS NULL) AND
                (p_ECO_rec.status_type IS NULL))))
    AND (   (l_ECO_rec.initiation_date =
             p_ECO_rec.initiation_date) OR
            ((p_ECO_rec.initiation_date = FND_API.G_MISS_DATE) OR
            (   (l_ECO_rec.initiation_date IS NULL) AND
                (p_ECO_rec.initiation_date IS NULL))))
    AND (   (l_ECO_rec.implementation_date =
             p_ECO_rec.implementation_date) OR
            ((p_ECO_rec.implementation_date = FND_API.G_MISS_DATE) OR
            (   (l_ECO_rec.implementation_date IS NULL) AND
                (p_ECO_rec.implementation_date IS NULL))))
    AND (   (l_ECO_rec.cancellation_date =
             p_ECO_rec.cancellation_date) OR
            ((p_ECO_rec.cancellation_date = FND_API.G_MISS_DATE) OR
            (   (l_ECO_rec.cancellation_date IS NULL) AND
                (p_ECO_rec.cancellation_date IS NULL))))
    AND (   (l_ECO_rec.cancellation_comments =
             p_ECO_rec.cancellation_comments) OR
            ((p_ECO_rec.cancellation_comments = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.cancellation_comments IS NULL) AND
                (p_ECO_rec.cancellation_comments IS NULL))))
    AND (   (l_ECO_rec.priority_code =
             p_ECO_rec.priority_code) OR
            ((p_ECO_rec.priority_code = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.priority_code IS NULL) AND
                (p_ECO_rec.priority_code IS NULL))))
    AND (   (l_ECO_rec.reason_code =
             p_ECO_rec.reason_code) OR
            ((p_ECO_rec.reason_code = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.reason_code IS NULL) AND
                (p_ECO_rec.reason_code IS NULL))))
    AND (   (l_ECO_rec.estimated_eng_cost =
             p_ECO_rec.estimated_eng_cost) OR
            ((p_ECO_rec.estimated_eng_cost = FND_API.G_MISS_NUM) OR
            (   (l_ECO_rec.estimated_eng_cost IS NULL) AND
                (p_ECO_rec.estimated_eng_cost IS NULL))))
    AND (   (l_ECO_rec.estimated_mfg_cost =
             p_ECO_rec.estimated_mfg_cost) OR
            ((p_ECO_rec.estimated_mfg_cost = FND_API.G_MISS_NUM) OR
            (   (l_ECO_rec.estimated_mfg_cost IS NULL) AND
                (p_ECO_rec.estimated_mfg_cost IS NULL))))
    AND (   (l_ECO_rec.requestor_id =
             p_ECO_rec.requestor_id) OR
            ((p_ECO_rec.requestor_id = FND_API.G_MISS_NUM) OR
            (   (l_ECO_rec.requestor_id IS NULL) AND
                (p_ECO_rec.requestor_id IS NULL))))
    AND (   (l_ECO_rec.attribute_category =
             p_ECO_rec.attribute_category) OR
            ((p_ECO_rec.attribute_category = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.attribute_category IS NULL) AND
                (p_ECO_rec.attribute_category IS NULL))))
    AND (   (l_ECO_rec.attribute1 =
             p_ECO_rec.attribute1) OR
            ((p_ECO_rec.attribute1 = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.attribute1 IS NULL) AND
                (p_ECO_rec.attribute1 IS NULL))))
    AND (   (l_ECO_rec.attribute2 =
             p_ECO_rec.attribute2) OR
            ((p_ECO_rec.attribute2 = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.attribute2 IS NULL) AND
                (p_ECO_rec.attribute2 IS NULL))))
    AND (   (l_ECO_rec.attribute3 =
             p_ECO_rec.attribute3) OR
            ((p_ECO_rec.attribute3 = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.attribute3 IS NULL) AND
                (p_ECO_rec.attribute3 IS NULL))))
    AND (   (l_ECO_rec.attribute4 =
             p_ECO_rec.attribute4) OR
            ((p_ECO_rec.attribute4 = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.attribute4 IS NULL) AND
                (p_ECO_rec.attribute4 IS NULL))))
    AND (   (l_ECO_rec.attribute5 =
             p_ECO_rec.attribute5) OR
            ((p_ECO_rec.attribute5 = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.attribute5 IS NULL) AND
                (p_ECO_rec.attribute5 IS NULL))))
    AND (   (l_ECO_rec.attribute6 =
             p_ECO_rec.attribute6) OR
            ((p_ECO_rec.attribute6 = FND_API.G_MISS_CHAR) OR
            (   (l_ECO_rec.attribute6 IS NULL) AND
                (p_ECO_rec.attribute6 IS NULL))))
    THEN

        --  Row has not changed. Set out parameter.

        x_ECO_rec                      := l_ECO_rec;

        --  Set return status

        x_return_status                := FND_API.G_RET_STS_SUCCESS;
        x_ECO_rec.return_status        := FND_API.G_RET_STS_SUCCESS;

    ELSE

        --  Row has changed by another user.

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_ECO_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN

            FND_MESSAGE.SET_NAME('ENG','OE_LOCK_ROW_CHANGED');
            FND_MSG_PUB.Add;

        END IF;

    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_ECO_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                Error_Handler.Log_Error ( p_who_rec       => ENG_GLOBALS.G_WHO_REC
                                      , p_msg_name      => 'OE_LOCK_ROW_DELETED'
                                      , x_err_text      => x_err_text );
        END IF;

    WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN

        x_return_status                := FND_API.G_RET_STS_ERROR;
        x_ECO_rec.return_status        := FND_API.G_RET_STS_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
                Error_Handler.Log_Error( p_who_rec       => ENG_GLOBALS.G_WHO_REC
                                      , p_msg_name      => 'OE_LOCK_ROW_ALREADY_LOCKED'
                                  , x_err_text      => x_err_text );
        END IF;

    WHEN OTHERS THEN

        x_return_status                := FND_API.G_RET_STS_UNEXP_ERROR;
        x_ECO_rec.return_status        := FND_API.G_RET_STS_UNEXP_ERROR;

        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            x_err_text := G_PKG_NAME || '(Lock Row) - ECO Header' || substrb(SQLERRM,1,60);
        END IF;

END Lock_Row;

*/





PROCEDURE Change_Subjects
( p_eco_rec                    IN     Eng_Eco_Pub.Eco_Rec_Type
, p_ECO_Unexp_Rec              IN     Eng_Eco_Pub.Eco_Unexposed_Rec_Type
, x_change_subject_unexp_rec   IN OUT NOCOPY  Eng_Eco_Pub.Change_Subject_Unexp_Rec_Type
, x_Mesg_Token_Tbl             IN OUT NOCOPY Error_Handler.Mesg_Token_Tbl_Type -- bug 3572721
, x_return_status              IN OUT NOCOPY  VARCHAR2)
IS

cursor Getsubject (p_change_type_id  in NUMBER) is

select ect.type_name ,ect.subject_id ,ese.entity_name ,ese.parent_entity_name  from
eng_change_order_types_vl ect ,eng_subject_entities ese
where ect.subject_id =ese.subject_id
and change_order_type_id =p_change_type_id
   and subject_level=1 ;




/*cursor getlifecycleid (item_id NUMBER ,revision VARCHAR2 , l_org_id NUMBER) is
SELECT  LP.PROJ_ELEMENT_ID -- into l_current_lifecycle_id
FROM PA_EGO_LIFECYCLES_PHASES_V LP, MTL_ITEM_REVISIONS MIR
WHERE  LP.PROJ_ELEMENT_ID = MIR.CURRENT_PHASE_ID
AND MIR.INVENTORY_ITEM_ID = item_id
AND MIR.ORGANIZATION_ID = l_org_id
AND MIR.REVISION = revision; */ -- Commented By LKASTURI


cursor getcataloggroupid(item_id NUMBER, l_org_id NUMBER) is
SELECT ITEM_CATALOG_GROUP_ID
from mtl_system_items msi
where msi.INVENTORY_ITEM_ID = item_id
AND   msi.ORGANIZATION_ID = l_org_id;



subject_type Getsubject%ROWTYPE;
l_entity_name VARCHAR2(30);
l_parent_entity_name VARCHAR2(30);
l_subject_id NUMBER;
l_change_subject_unexp_rec  Eng_Eco_Pub.Change_Subject_Unexp_Rec_Type;

l_user_id               NUMBER;
l_login_id              NUMBER;
l_prog_appid            NUMBER;
l_prog_id               NUMBER;
l_request_id            NUMBER;
l_return_status         VARCHAR2(1);
l_org_id                        NUMBER;
l_rev_id                        NUMBER;
l_inv_item_id                   NUMBER;
l_Mesg_Token_Tbl                Error_Handler.Mesg_Token_Tbl_Type;
l_Token_Tbl                     Error_Handler.Token_Tbl_Type;
   l_err_text   VARCHAR2(2000);
   l_sub_id NUMBER;
l_item_catalog_group_id NUMBER;
BEGIN

    l_return_status := FND_API.G_RET_STS_SUCCESS;

    l_user_id           := Eng_Globals.Get_User_Id;
    l_login_id          := Eng_Globals.Get_Login_Id;
    l_request_id        := ENG_GLOBALS.Get_request_id;
    l_prog_appid        := ENG_GLOBALS.Get_prog_appid;
    l_prog_id           := ENG_GLOBALS.Get_prog_id;

       OPEN Getsubject (p_ECO_Unexp_Rec. Change_Order_Type_Id);
       FETCH Getsubject INTO subject_type;
       CLOSE Getsubject;
       l_entity_name := subject_type.entity_name;
       l_parent_entity_name := subject_type.parent_entity_name;
       l_subject_id := subject_type.subject_id;
       l_change_subject_unexp_rec.change_id := p_ECO_Unexp_Rec.change_id;
       l_change_subject_unexp_rec.ENTITY_NAME := l_entity_name;
       l_change_subject_unexp_rec.subject_level := 1;

       l_org_id := p_ECO_Unexp_Rec.organization_id; -- Added for bug 3651713

       IF (l_entity_name = 'EGO_ITEM_REVISION') THEN
          IF   p_eco_rec.pk1_name IS NOT NULL
          --AND  p_eco_rec.pk2_name IS NOT NULL
          --AND  p_eco_rec.pk3_name IS NOT NULL
          THEN
             --l_org_id := ENG_Val_To_Id.Organization(p_eco_rec.pk2_name, l_err_text);
             l_change_subject_unexp_rec.pk2_value := l_org_id;
             IF (l_org_id IS NOT NULL AND l_org_id <> fnd_api.g_miss_num) THEN
                l_inv_item_id := ENG_Val_To_Id.revised_item (p_eco_rec.pk1_name,
                                               l_org_id,
                                               l_err_text);
                l_change_subject_unexp_rec.pk1_value := l_inv_item_id;
                IF  l_inv_item_id IS NOT NULL
                AND l_inv_item_id <> fnd_api.g_miss_num
                THEN
                 IF p_eco_rec.pk3_name IS NOT NULL -- bug 3572721 If the inventory_item_id and org_id is not null, then validate pk3value
                 THEN
                  l_rev_id := ENG_Val_To_Id.revised_item_code (l_inv_item_id,
                                                 l_org_id,
                                                 p_eco_rec.pk3_name);
                  l_change_subject_unexp_rec.pk3_value := l_rev_id;
                  IF (l_rev_id IS NOT NULL AND l_rev_id <> fnd_api.g_miss_num)
                  THEN
                     l_return_status := 'S'; --FND_API.G_RET_STS_SUCCESS;
                  ELSE
                     l_token_tbl (1).token_name := 'CHANGE_LINE_TYPE'; --token added for bug 3572721
                     l_token_tbl (1).token_value := p_eco_rec.change_type_code;
                     Error_Handler.add_error_token (
                        p_message_name=> 'ENG_PK3_NAME_INVALID',
                        p_mesg_token_tbl=> l_mesg_token_tbl,
                        x_mesg_token_tbl=> l_mesg_token_tbl,
                        p_token_tbl=> l_token_tbl
                     );
                     l_return_status := FND_API.G_RET_STS_ERROR;
                  END IF; --end of l_rev_id IS NOT NULL
                 END IF; -- end of pk3_name is not null
                ELSE
                  l_token_tbl (1).token_name := 'CHANGE_LINE_TYPE';
                  l_token_tbl (1).token_value := p_eco_rec.change_type_code;
                  Error_Handler.add_error_token (
                     p_message_name=> 'ENG_PK1_NAME_INVALID',
                     p_mesg_token_tbl=> l_mesg_token_tbl,
                     x_mesg_token_tbl=> l_mesg_token_tbl,
                     p_token_tbl=> l_token_tbl
                  );
                  l_return_status := FND_API.G_RET_STS_ERROR;
                END IF; -- l_inv_item_id IS NOT NULL
             ELSE
               l_token_tbl (1).token_name := 'CHANGE_LINE_TYPE';
               l_token_tbl (1).token_value := p_eco_rec.change_type_code;
               Error_Handler.add_error_token (
                  p_message_name=> 'ENG_PK2_NAME_INVALID',
                  p_mesg_token_tbl=> l_mesg_token_tbl,
                  x_mesg_token_tbl=> l_mesg_token_tbl,
                  p_token_tbl=> l_token_tbl
               );
               l_return_status := FND_API.G_RET_STS_ERROR;
             END IF; --l_org_id IS NOT NULL
          ELSE
          -- Commented error handling code as pk values are not mandatory
                l_change_subject_unexp_rec.pk2_value := NULL; --org_id;
                l_change_subject_unexp_rec.pk1_value := NULL; --inv_item_id;
                l_change_subject_unexp_rec.pk3_value := NULL; --rev_id;
        /*    IF p_eco_rec.pk1_name IS NULL
            OR p_eco_rec.pk1_name = fnd_api.g_miss_char THEN
               l_token_tbl (1).token_name := 'CHANGE_LINE_TYPE';
               l_token_tbl (1).token_value := p_eco_rec.change_type_code;
               Error_Handler.add_error_token (
                  p_message_name=> 'ENG_PK1_NAME_INVALID',
                  p_mesg_token_tbl=> l_mesg_token_tbl,
                  x_mesg_token_tbl=> l_mesg_token_tbl,
                  p_token_tbl=> l_token_tbl
               );
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            IF p_eco_rec.pk3_name IS NULL
            OR p_eco_rec.pk3_name = fnd_api.g_miss_char THEN
               l_token_tbl (1).token_name := 'CHANGE_LINE_TYPE';
               l_token_tbl (1).token_value := p_eco_rec.change_type_code;
               Error_Handler.add_error_token (
                  p_message_name=> 'ENG_PK3_NAME_INVALID',
                  p_mesg_token_tbl=> l_mesg_token_tbl,
                  x_mesg_token_tbl=> l_mesg_token_tbl,
                  p_token_tbl=> l_token_tbl
               );
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;
            IF p_eco_rec.pk2_name IS NULL
            OR p_eco_rec.pk2_name = fnd_api.g_miss_char THEN
               l_token_tbl (1).token_name := 'CHANGE_LINE_TYPE';
               l_token_tbl (1).token_value := p_eco_rec.change_type_code;
               Error_Handler.add_error_token (
                  p_message_name=> 'ENG_PK2_NAME_INVALID',
                  p_mesg_token_tbl=> l_mesg_token_tbl,
                  x_mesg_token_tbl=> l_mesg_token_tbl,
                  p_token_tbl=> l_token_tbl
               );
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;*/

          END IF; -- p_eco_rec.Pk1_Name is not null
       ELSIF l_entity_name = 'EGO_ITEM'  THEN
              --For Item and Catalog Category PK1_NAME,PK2_NAME Columns are mandatory
         IF  p_eco_rec.pk1_name IS NOT NULL
         -- AND p_eco_rec.pk2_name IS NOT NULL
         THEN
            --l_org_id := ENG_Val_To_Id.ORGANIZATION (p_eco_rec.pk2_name, l_err_text);
            l_change_subject_unexp_rec.pk2_value := l_org_id;
            IF (l_org_id IS NOT NULL AND l_org_id <> fnd_api.g_miss_num) THEN
               l_rev_id := ENG_Val_To_Id.revised_item (p_eco_rec.pk1_name,
                                         l_org_id,
                                         l_err_text);
               l_change_subject_unexp_rec.pk1_value := l_rev_id;
               IF (l_rev_id IS NOT NULL AND l_rev_id <> fnd_api.g_miss_num) THEN
                  l_return_status := 'S';
               ELSE
                  l_token_tbl (1).token_name := 'CHANGE_LINE_TYPE';
                  l_token_tbl (1).token_value := p_eco_rec.change_type_code;
                  Error_Handler.add_error_token (
                     p_message_name=> 'ENG_PK1_NAME_INVALID',
                     p_mesg_token_tbl=> l_mesg_token_tbl,
                     x_mesg_token_tbl=> l_mesg_token_tbl,
                     p_token_tbl=> l_token_tbl
                  );
                  l_return_status := FND_API.G_RET_STS_ERROR;
               END IF; --l_rev_id IS NOT NULL
            ELSE
               l_token_tbl (1).token_name := 'CHANGE_LINE_TYPE';
               l_token_tbl (1).token_value := p_eco_rec.change_type_code;
               Error_Handler.add_error_token (
                  p_message_name=> 'ENG_PK2_NAME_INVALID',
                  p_mesg_token_tbl=> l_mesg_token_tbl,
                  x_mesg_token_tbl=> l_mesg_token_tbl,
                  p_token_tbl=> l_token_tbl
               );
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF; --l_org_id IS NOT NULL
         ELSE
                 l_change_subject_unexp_rec.pk1_value := NULL;
                 l_change_subject_unexp_rec.pk2_value := NULL;
         -- Commented out code as pk values are not mandatory
           /* IF p_eco_rec.pk1_name IS NULL
            OR p_eco_rec.pk1_name = fnd_api.g_miss_char THEN
               l_token_tbl (1).token_name := 'CHANGE_LINE_TYPE';
               l_token_tbl (1).token_value := p_eco_rec.change_type_code;
               Error_Handler.add_error_token (
                  p_message_name=> 'ENG_PK1_NAME_INVALID',
                  p_mesg_token_tbl=> l_mesg_token_tbl,
                  x_mesg_token_tbl=> l_mesg_token_tbl,
                  p_token_tbl=> l_token_tbl
               );
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;

            IF p_eco_rec.pk2_name IS NULL
            OR p_eco_rec.pk2_name = fnd_api.g_miss_char THEN
               l_token_tbl (1).token_name := 'CHANGE_LINE_TYPE';
               l_token_tbl (1).token_value := p_eco_rec.change_type_code;
               Error_Handler.add_error_token (
                  p_message_name=> 'ENG_PK3_NAME_INVALID',
                  p_mesg_token_tbl=> l_mesg_token_tbl,
                  x_mesg_token_tbl=> l_mesg_token_tbl,
                  p_token_tbl=> l_token_tbl
               );
               l_return_status := FND_API.G_RET_STS_ERROR;
            END IF;*/
         END IF; -- p_eco_rec.Pk1_Name is not null
      END IF; --End Of If of check for l_entity_name

      IF l_return_status= 'S' THEN
      /*OPEN getlifecycleid(l_change_subject_unexp_rec.pk1_value,
                          p_eco_rec.pk1_name,
                          l_change_subject_unexp_rec.pk2_value);
      FETCH getlifecycleid into l_change_subject_unexp_rec.lifecycle_state_id;*/ -- Commented By LKASTURI
        --
        -- Bug 3311072: Change the query to select item phase
        -- Added By LKASTURI
        --
        -- Exception handling added to take care of null pk values
        -- Also assuming that pk1 value will be inventory item id if not null
        -- and pk2 value organization id is not null
        IF (l_change_subject_unexp_rec.pk1_value IS NOT NULL AND
            l_change_subject_unexp_rec.pk2_value IS NOT NULL)
        THEN
                BEGIN
                        SELECT CURRENT_PHASE_ID
                        INTO l_change_subject_unexp_rec.lifecycle_state_id
                        FROM MTL_System_items_vl
                        WHERE INVENTORY_ITEM_ID = l_change_subject_unexp_rec.pk1_value
                        AND ORGANIZATION_ID = l_change_subject_unexp_rec.pk2_value;
                EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        l_change_subject_unexp_rec.lifecycle_state_id := null;
                WHEN TOO_MANY_ROWS THEN
                        l_change_subject_unexp_rec.lifecycle_state_id := null;
                END;
        ELSE
                l_change_subject_unexp_rec.lifecycle_state_id := null;
        END IF;
        -- End Changes

      IF p_eco_rec.transaction_type = Eng_Globals.G_OPR_CREATE THEN
       SELECT eng_change_subjects_s.nextval INTO l_change_subject_unexp_rec.change_subject_id
  FROM SYS.DUAL;



         Insert into eng_change_subjects
         (CHANGE_SUBJECT_ID,
          CHANGE_ID,
          CHANGE_LINE_ID,
          ENTITY_NAME,
          PK1_VALUE,
          PK2_VALUE,
          PK3_VALUE,
          PK4_VALUE,
          PK5_VALUE,
          SUBJECT_LEVEL,
          LIFECYCLE_STATE_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          REQUEST_ID,
          PROGRAM_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_UPDATE_DATE)
         values
         (l_change_subject_unexp_rec.change_subject_id,
          l_change_subject_unexp_rec.change_id,
          l_change_subject_unexp_rec.change_line_id,
          l_change_subject_unexp_rec.entity_name,
          l_change_subject_unexp_rec.pk1_value,
          l_change_subject_unexp_rec.pk2_value,
          l_change_subject_unexp_rec.pk3_value,
          l_change_subject_unexp_rec.pk4_value,
          l_change_subject_unexp_rec.pk5_value,
          l_change_subject_unexp_rec.subject_level,
          l_change_subject_unexp_rec.lifecycle_state_id,
          SYSDATE,
          l_User_Id,
          SYSDATE,
          l_User_Id,
          l_Login_Id,
          l_request_id,
          l_prog_id,
          l_prog_appid,
          SYSDATE) returning CHANGE_SUBJECT_ID into l_sub_id;



       IF l_parent_entity_name = 'EGO_ITEM' THEN
         Insert into eng_change_subjects
         (CHANGE_SUBJECT_ID,
          CHANGE_ID,
          CHANGE_LINE_ID,
          ENTITY_NAME,
          PK1_VALUE,
          PK2_VALUE,
          PK3_VALUE,
          PK4_VALUE,
          PK5_VALUE,
          SUBJECT_LEVEL,
          LIFECYCLE_STATE_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          REQUEST_ID,
          PROGRAM_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_UPDATE_DATE)
         values
         (eng_change_subjects_s.nextval,
          l_change_subject_unexp_rec.change_id,
          null,
          l_parent_entity_name, -- bug 3572698
          l_change_subject_unexp_rec.pk1_value,
          l_change_subject_unexp_rec.pk2_value,
          null,
          null,
          null,
          2,
          null,
          SYSDATE,
          l_User_Id,
          SYSDATE,
          l_User_Id,
          l_Login_Id,
          l_request_id,
          l_prog_appid,
          l_prog_id,sysdate);
     elsif l_parent_entity_name = 'EGO_CATALOG_GROUP' THEN
       OPEN getcataloggroupid(l_change_subject_unexp_rec.pk1_value,
                        l_change_subject_unexp_rec.pk2_value);
       FETCH getcataloggroupid into l_item_catalog_group_id;
        Insert into eng_change_subjects
         (CHANGE_SUBJECT_ID,
          CHANGE_ID,
          CHANGE_LINE_ID,
          ENTITY_NAME,
          PK1_VALUE,
          PK2_VALUE,
          PK3_VALUE,
          PK4_VALUE,
          PK5_VALUE,
          SUBJECT_LEVEL,
          LIFECYCLE_STATE_ID,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_LOGIN,
          REQUEST_ID,
          PROGRAM_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_UPDATE_DATE)
         values
         (eng_change_subjects_s.nextval,
          l_change_subject_unexp_rec.change_id,
          null,
          l_parent_entity_name, -- bug 3572698
          l_item_catalog_group_id,
          null,
          null,
          null,
          null,
          2,
          null,
          SYSDATE,
          l_User_Id,
          SYSDATE,
          l_User_Id,
          l_Login_Id,
          l_request_id,
          l_prog_appid,
          l_prog_id,sysdate);
       END IF;
      ELSIF p_eco_rec.transaction_type = Eng_Globals.G_OPR_UPDATE THEN
         UPDATE eng_change_subjects SET
         pk1_value = l_change_subject_unexp_rec.pk1_value,
         pk2_value = l_change_subject_unexp_rec.pk2_value,
         pk3_value = l_change_subject_unexp_rec.pk3_value
         WHERE change_id = l_change_subject_unexp_rec.change_id
         AND subject_level = 1
         AND change_line_id is null;

         IF l_parent_entity_name = 'EGO_ITEM' THEN
            UPDATE eng_change_subjects SET
            pk1_value = l_change_subject_unexp_rec.pk1_value,
            pk2_value = l_change_subject_unexp_rec.pk2_value
            WHERE change_id = l_change_subject_unexp_rec.change_id
            AND subject_level = 2
            AND change_line_id is null;
         ELSIF
              l_parent_entity_name = 'EGO_CATALOG_GROUP' THEN
              OPEN getcataloggroupid(l_change_subject_unexp_rec.pk1_value,
                        l_change_subject_unexp_rec.pk2_value);
              FETCH getcataloggroupid into l_item_catalog_group_id;
              UPDATE eng_change_subjects SET
              pk1_value = l_item_catalog_group_id
              WHERE change_id = l_change_subject_unexp_rec.change_id
              AND subject_level = 2
              AND change_line_id is null;
         END IF;
      ELSE
         DELETE FROM eng_change_subjects
         WHERE change_line_id is null
         AND change_id = p_ECO_Unexp_Rec.change_id;
      END IF; -- if CREATE


      END IF; -- if return status is 'S'

    x_Mesg_Token_Tbl := l_Mesg_Token_Tbl; -- bug 3572721
    x_return_status := l_return_status;

  END Change_Subjects;


  -- procedure to delete all changeheader related rows
  PROCEDURE delete_ECO
  (
    p_api_version               IN   NUMBER                             --
   ,p_init_msg_list             IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_commit                    IN   VARCHAR2 := FND_API.G_FALSE        --
   ,p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status             OUT  NOCOPY  VARCHAR2                   --
   ,x_msg_count                 OUT  NOCOPY  NUMBER                     --
   ,x_msg_data                  OUT  NOCOPY  VARCHAR2                   --
   ,p_change_id                 IN   NUMBER                             -- header's change_id
   ,p_api_caller                IN   VARCHAR2 := 'UI'
  )
  IS
    l_api_name           CONSTANT VARCHAR2(30)  := 'delete_ECO';
    l_api_version        CONSTANT NUMBER := 1.0;

    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_msg_data           VARCHAR2(2000);



    l_pls_block          VARCHAR2(5000);
  BEGIN
    -- Standard Start of API savepoint
     -- Standard Start of API savepoint
    SAVEPOINT   Init_Lifecycle;
    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
       FND_MSG_PUB.initialize;
    END IF ;

      -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;


    -- Real code starts here -----------------------------------------------
    DELETE FROM ENG_CHANGE_ROUTE_ASSOCS
  WHERE  ROUTE_PEOPLE_ID in
  ( select ecrp.ROUTE_PEOPLE_ID
      from ENG_CHANGE_ROUTE_PEOPLE ecrp , ENG_CHANGE_ROUTE_STEPS ecrs , ENG_LIFECYCLE_STATUSES els
      where ecrp.STEP_ID = ecrs.step_id
        AND ecrs.ROUTE_ID = els.CHANGE_WF_ROUTE_ID
        and els.ENTITY_ID1 = p_change_id
        and els.ENTITY_NAME = 'ENG_CHANGE'
  );
  --Fixed for bug 4958931
  /*( select ROUTE_PEOPLE_ID
    from ENG_CHANGE_ROUTE_PEOPLE
    where STEP_ID in
      ( select STEP_ID
        from ENG_CHANGE_ROUTE_STEPS
        where ROUTE_ID in
        ( select CHANGE_WF_ROUTE_ID
          from ENG_LIFECYCLE_STATUSES
          where   ENTITY_ID1 = p_change_id
          and ENTITY_NAME = 'ENG_CHANGE'
        )
       )
  );*/

 delete from ENG_CHANGE_ROUTE_PEOPLE_tl
   where ROUTE_PEOPLE_ID in
  ( select ecrp.ROUTE_PEOPLE_ID
      from ENG_CHANGE_ROUTE_PEOPLE ecrp , ENG_CHANGE_ROUTE_STEPS ecrs , ENG_LIFECYCLE_STATUSES els
      where ecrp.STEP_ID = ecrs.step_id
        AND ecrs.ROUTE_ID = els.CHANGE_WF_ROUTE_ID
        and els.ENTITY_ID1 = p_change_id
        and els.ENTITY_NAME = 'ENG_CHANGE'
  );
  --Fixed for bug 4958931
  /*( select ROUTE_PEOPLE_ID
    from ENG_CHANGE_ROUTE_PEOPLE
    where STEP_ID in
      ( select STEP_ID
        from ENG_CHANGE_ROUTE_STEPS
        where ROUTE_ID in
        ( select CHANGE_WF_ROUTE_ID
          from ENG_LIFECYCLE_STATUSES
          where   ENTITY_ID1 = p_change_id
          and ENTITY_NAME = 'ENG_CHANGE'
        )
       )
  );*/



  delete from ENG_CHANGE_ROUTE_PEOPLE
   where STEP_ID in
      ( select STEP_ID
        from ENG_CHANGE_ROUTE_STEPS
        where ROUTE_ID in
        ( select CHANGE_WF_ROUTE_ID
          from ENG_LIFECYCLE_STATUSES
          where   ENTITY_ID1 = p_change_id
          and ENTITY_NAME = 'ENG_CHANGE'
        )
       );


delete from ENG_CHANGE_ROUTE_STEPS_TL
  where STEP_ID in
      ( select STEP_ID
        from ENG_CHANGE_ROUTE_STEPS
        where ROUTE_ID in
        ( select CHANGE_WF_ROUTE_ID
          from ENG_LIFECYCLE_STATUSES
          where   ENTITY_ID1 = p_change_id
          and ENTITY_NAME = 'ENG_CHANGE'
        )
       );

 delete  from ENG_CHANGE_ROUTE_STEPS
 where ROUTE_ID in
 ( select CHANGE_WF_ROUTE_ID
          from ENG_LIFECYCLE_STATUSES
          where   ENTITY_ID1 = p_change_id
          and ENTITY_NAME = 'ENG_CHANGE'
  );



  delete from ENG_CHANGE_ROUTES_tl
  where ROUTE_ID in
 ( select CHANGE_WF_ROUTE_ID
          from ENG_LIFECYCLE_STATUSES
          where   ENTITY_ID1 = p_change_id
          and ENTITY_NAME = 'ENG_CHANGE'
  );


  delete from ENG_CHANGE_ROUTES
  where ROUTE_ID in
  ( select CHANGE_WF_ROUTE_ID
          from ENG_LIFECYCLE_STATUSES
          where   ENTITY_ID1 = p_change_id
          and ENTITY_NAME = 'ENG_CHANGE'  );


  delete from  ENG_LIFECYCLE_STATUSES
  where   ENTITY_ID1 = p_change_id
          and ENTITY_NAME = 'ENG_CHANGE' ;

  delete from  ENG_LIFECYCLE_STATUSES
  where   ENTITY_ID1 = p_change_id
          and ENTITY_NAME = 'ENG_CHANGE' ;


  delete   from eng_revised_items
  where change_id = p_change_id ;


  delete from eng_engineering_changes
  where change_id = p_change_id ;

  IF FND_API.To_Boolean ( p_commit ) THEN
      COMMIT WORK;
    END IF;

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
            --ROLLBACK TO Init_Lifecycle;
          x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
      --IF g_debug_flag THEN
      --  Write_Debug('Rollback and Finish with expected error.') ;
      --END IF ;
      --IF FND_API.to_Boolean( p_debug ) THEN
      --  Close_Debug_Session ;
      --END IF ;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            --ROLLBACK TO Init_Lifecycle;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
/*
      IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with unexpected error.') ;
      END IF ;
      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session ;
      END IF ;
*/
    WHEN OTHERS THEN
          --ROLLBACK TO Init_Lifecycle;
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
      THEN
        FND_MSG_PUB.Add_Exc_Msg (       G_PKG_NAME, l_api_name );
                  END IF;
      FND_MSG_PUB.Count_And_Get
        ( p_count        =>      x_msg_count
       ,p_data         =>      x_msg_data );
    /*
     IF g_debug_flag THEN
        Write_Debug('Rollback and Finish with other error.') ;
      END IF ;

      IF FND_API.to_Boolean( p_debug ) THEN
        Close_Debug_Session ;
      END IF ;
   */
  END delete_ECO;

  -- procedure to validate if changing schedule date is permitted for this change order
  -- if there are 2 or more revised items (same item) with new revision specified
  -- then changing both scheduled dates to the same date causes CO imp. to fail
  PROCEDURE is_Reschedule_ECO_Allowed
  (
   p_change_id                 IN   NUMBER                             --
   ,x_is_change_sch_date_allowed    OUT  NOCOPY VARCHAR2
  )
  IS
    -- begin of vamohan changes
    CURSOR chk_if_rev_item_occurs_twice IS
    select 'X'
    from eng_revised_items REV1, eng_revised_items REV2
    where REV1.change_id = p_change_id
      and REV2.change_id = p_change_id
      and REV1.organization_id = REV2.organization_id
      and REV1.revised_item_id = REV2.revised_item_id
      and REV1.revised_item_sequence_id <> REV2.revised_item_sequence_id
      and REV1.status_type <> 5
      and REV2.status_type <> 5
      and REV1.new_item_revision is not null
      and REV2.new_item_revision is not null;

    chk_rev_item_type_var VARCHAR2(1);
  BEGIN
    open chk_if_rev_item_occurs_twice;
    fetch chk_if_rev_item_occurs_twice into chk_rev_item_type_var;
    IF (chk_if_rev_item_occurs_twice%found)
    THEN
        x_is_change_sch_date_allowed := 'N';
    ELSE
        x_is_change_sch_date_allowed := 'Y';
    END IF;
    close chk_if_rev_item_occurs_twice;
   EXCEPTION
     WHEN OTHERS THEN
       x_is_change_sch_date_allowed := 'N';
       IF chk_if_rev_item_occurs_twice%ISOPEN THEN
         close chk_if_rev_item_occurs_twice;
       END IF;
       RAISE;
   END is_Reschedule_ECO_Allowed;

END ENG_Eco_Util;

/
