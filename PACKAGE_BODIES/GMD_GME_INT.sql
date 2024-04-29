--------------------------------------------------------
--  DDL for Package Body GMD_GME_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_GME_INT" AS
/* $Header: GMDGMEIB.pls 120.4.12010000.2 2008/11/13 20:02:50 asatpute ship $ */

--	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
   --Bug 3222090, magupta removed call to FND_PROFILE.VALUE('AFLOG_ENABLED')
   --forward decl.
   function set_debug_flag return varchar2;
   --l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
   l_debug VARCHAR2(1) := set_debug_flag;

   FUNCTION set_debug_flag RETURN VARCHAR2 IS
   l_debug VARCHAR2(1):= 'N';
   BEGIN
    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
      l_debug := 'Y';
    END IF;
    RETURN l_debug;
   END set_debug_flag;

PROCEDURE check_qc(
      p_recipeid         IN NUMBER,
      p_routingid        IN NUMBER,
      p_routingstepid    IN NUMBER,
      p_organization_id  IN NUMBER DEFAULT NULL,
      p_resultout        OUT NOCOPY VARCHAR2)

   IS

   L_INVENTORY_ITEM_ID            NUMBER;
   L_ORGANIZATION_ID              NUMBER;
   l_revision                     VARCHAR2(3); --RLNAGARA B5389806 Added revision.
   L_RECIPE_ID                    NUMBER;
   L_FORMULA_ID                   NUMBER;
   L_FORMULALINE_ID               NUMBER;
   L_ROUTING_ID                   NUMBER ;
   L_STEP_ID                      NUMBER;
   L_STEP_NO                      NUMBER ;
   L_OPRN_ID                      NUMBER ;
   L_EXACT_MATCH                  VARCHAR2(1);
   L_SPEC_ID                      NUMBER ;
   L_SPEC_VR_ID                   NUMBER ;
   L_RETURN_STATUS                VARCHAR2(100) ;
   L_Msg_DATA                 VARCHAR2(2000)  ;
   l_wip_spec   GMD_SPEC_MATCH_GRP.WIP_SPEC_REC_TYPE;
   l_log varchar2(4000);
   dummy number;
   l_routingstepid number;
   l_last_update_by                   NUMBER ;


 Cursor C1(x_routing_id number,x_routing_step_id number , x_recipe_id number) is
  SELECT C.OWNER_ORGANIZATION_ID,         C.ROUTING_ID,
        C.RECIPE_ID,	C.FORMULA_ID,
        C.ROUTING_ID
	--MATL.ITEM_ID,
        --MATL.FORMULALINE_ID
	,FM.OPRN_ID
        ,FM.ROUTINGSTEP_ID
	FROM	GMD_RECIPES_B C,
		FM_FORM_MST H,
		fm_rout_dtl FM
		--,FM_MATL_DTL MATL
	WHERE
		C.ROUTING_ID= x_routing_id AND
		C.RECIPE_ID = x_recipe_id AND
		FM.ROUTINGSTEP_ID= x_routing_step_id and
		H.formula_id = C.Formula_id
		AND FM.routing_id = C.routing_ID
		--AND c.FORMULA_ID = MATL.FORMULA_ID
		--AND h.FORMULA_ID = MATL.FORMULA_ID
		;

  Cursor C2 (p_recipe_id number) is
    select distinct md.inventory_item_id,md.revision    ----RLNAGARA B5389806 Added revision
    ,md.formulaline_id          ----SMALLURU B6379386 Added formulaline_id
    from fm_matl_dtl md, gmd_Recipes_b r
    where r.recipe_id = p_recipe_id
    and r.formula_id = md.formula_id
    and md.line_type <> 2;   -- no byproducts


 BEGIN

     --Bug 4523278. If profile GMD:Batch step sample required is set to No
     --set p_resultout to 'F'(No Sample Required) and RETURN.
     IF NVL(FND_PROFILE.VALUE('GMD_BATCH_STEP_SMPL_REQD'), 'Y') = 'N' THEN
        p_resultout := 'F';
        RETURN;
     END IF;

	IF (l_debug = 'Y') THEN
	       gmd_debug.log_initialize('GMDGMEInt');
	END IF;

	IF (l_debug = 'Y') THEN
	       gmd_debug.put_line('recipe ID ' || p_recipeid);
	       gmd_debug.put_line('routing ID ' || p_routingid);
	       gmd_debug.put_line('routing step ID ' || p_routingstepid);
	END IF;

	/* For a given recipe id, routing id, routingstepid combination */
          OPEN C1(p_routingid,p_routingstepid,p_recipeid);
             wf_log_pkg.string(6, 'Dummy','Before Fetching the values.');
             Fetch C1 into L_ORGANIZATION_ID,L_ROUTING_ID,L_RECIPE_ID,
                         L_FORMULA_ID,L_ROUTING_ID,
			 --L_ITEM_ID,L_FORMULALINE_ID,
			 L_OPRN_ID,
			 l_routingstepid ;
          CLOSE C1;

          l_wip_spec.organization_id  := p_organization_id;
          l_wip_spec.batch_id         := NULL;
          l_wip_spec.recipe_id        := L_recipe_id;
          l_wip_spec.formula_id       := L_formula_id;
          l_wip_spec.formulaline_id   := L_formulaline_id;
          l_wip_spec.routing_id       := L_routing_id;
          l_wip_spec.step_id          := l_routingstepid;
          l_wip_spec.step_no          := NULL;
          l_wip_spec.oprn_id          := L_oprn_id;
          l_wip_spec.charge           := NULL;
          l_wip_spec.date_effective   := SYSDATE;
          l_wip_spec.exact_match      := 'N';

/* Bug No.7032231 - Commented the following code as it is not supporting to get spec details  */

	/*  IF (l_wip_spec.step_no IS NOT NULL or l_wip_spec.step_id IS NOT NULL) THEN
		   l_wip_spec.find_spec_with_step      := 'Y';
	  ELSE
		   l_wip_spec.find_spec_with_step      := 'N';
	  END IF; */


          open C2(p_recipeid) ;
          LOOP

               Fetch C2 into l_inventory_item_id,l_revision ,l_formulaline_id;
	       exit when C2%notfound ;

               l_wip_spec.inventory_item_id  := l_inventory_item_id;
               l_wip_spec.revision := l_revision;                   --RLNAGARA B5389806 Added revision
	       l_wip_spec.formulaline_id   := l_formulaline_id; --Bug#6379386
               l_step_id           := l_routingstepid;

	       IF (l_debug = 'Y') THEN
		       gmd_debug.put_line('Checking if WIP Spec exists ');
	       END IF;

               IF GMD_SPEC_MATCH_GRP.FIND_WIP_SPEC(
       				 p_wip_spec_rec       => l_wip_spec,
        			 x_spec_id            => l_spec_id,
        			 x_spec_vr_id         => l_spec_vr_id,
        			 x_return_status      => l_return_status,
        			 x_message_data       => l_msg_data) THEN

		         IF (l_debug = 'Y') THEN
			       gmd_debug.put_line('WIP Spec exists ');
	        	 END IF;

			 p_resultout:='S';
			 EXIT;
 	        else
		     p_resultout:='F';
	        END IF;

	   END LOOP ;
	   CLOSE C2;


      IF l_step_id is NULL THEN
	     p_resultout:='F';
      end if ;

      IF (l_debug = 'Y') THEN
	       gmd_debug.put_line('p_resultout  ' || p_resultout);
      END IF;


  EXCEPTION
      WHEN OTHERS THEN
      p_resultout:='F';
      GMD_API_PUB.Log_Message('GMD_GME_INT',
                            'PACKAGE','QM-GME QC status integration','ERROR', SUBSTR(SQLERRM,1,100));

      raise;

  END CHECK_QC;

END GMD_GME_INT ;

/
