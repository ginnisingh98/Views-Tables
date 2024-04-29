--------------------------------------------------------
--  DDL for Package Body AR_FLEXBUILDER_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AR_FLEXBUILDER_WF_PKG" AS
/* $Header: ARFLBMAB.pls 115.9 2002/11/18 21:44:20 anukumar ship $  */

FUNCTION SUBSTITUTE_BALANCING_SEGMENT ( X_ARFLEXNUM IN NUMBER
                                       ,X_ARORIGCCID IN NUMBER
                                       ,X_ARSUBSTICCID IN NUMBER
                                       ,X_return_ccid IN OUT NOCOPY number
                                       ,X_concat_segs IN OUT NOCOPY varchar2
                                       ,X_concat_ids  IN OUT NOCOPY varchar2
                                       ,X_concat_descrs IN OUT NOCOPY varchar2
                                       ,X_ARERROR IN OUT NOCOPY VARCHAR2 ) RETURN BOOLEAN IS

itemtype varchar2(30) := 'ARSBALSG';
itemkey  varchar2(30);
result   boolean;
l_itemkey  varchar2(30); -- Bug 1936354.
l_new_combination  boolean;  -- Bug 1936354.
l_insert_if_new varchar2(10); -- Bug 1936354
l_insert_new boolean; -- Bug 1936354

BEGIN
   --arp_standard.debug('AR_FLEXBUILDER_WF_PKG.SUBSTITUTE_BALANCING_SEGMENT (+) ');
   --arp_standard.debug('Orig Ccid = ' || to_char(X_ARORIGCCID));
   --arp_standard.debug('Substi Ccid = ' || to_Char(X_ARSUBSTICCID));


   itemkey := FND_FLEX_WORKFLOW.INITIALIZE ( 'SQLGL'
                                             ,'GL#'
                                             ,X_ARFLEXNUM
                                             ,'ARSBALSG');

   -- Initialize the WorkFlow Item Attributes

   wf_engine.SetItemAttrNumber ( itemtype => itemtype
                                ,itemkey  => itemkey
                                ,aname    => 'CHART_OF_ACCOUNTS_ID'
                                ,avalue   => X_ARFLEXNUM );

   wf_engine.SetItemAttrNumber ( itemtype => itemtype
                                ,itemkey  => itemkey
                                ,aname    => 'ARORIGCCID'
                                ,avalue   => X_ARORIGCCID);

   wf_engine.SetItemAttrNumber ( itemtype => itemtype
                                ,itemkey  => itemkey
                                ,aname    => 'ARSUBSTICCID'
                                ,avalue   => X_ARSUBSTICCID);

 -- Bug 1936354 : Comment the below code, added the new code below comments.

/*
   result := FND_FLEX_WORKFLOW.GENERATE('ARSBALSG'
                                       ,itemkey
                                       ,X_return_ccid
                                       ,X_concat_segs
                                       ,X_concat_ids
                                       ,X_concat_descrs
                                       ,X_ARERROR);
*/

     --  Bug 1936354

           BEGIN
		SELECT 	DYNAMIC_INSERTS_ALLOWED_FLAG
		INTO   	l_insert_if_new
		FROM 	fnd_id_flex_Structures ffs,
		       	ar_system_parameters asp,
     			gl_sets_of_books glsob
		WHERE   ffs.APPLICATION_ID = 101
		AND   	ffs.ID_FLEX_CODE = 'GL#'
		AND   	ffs.ID_FLEX_NUM = glsob.chart_of_accounts_id
		AND   	glsob.set_of_books_id = asp.set_of_books_id;

	    EXCEPTION
  			WHEN OTHERS THEN l_insert_if_new := 'N';
       	    END;

  IF l_insert_if_new = 'Y' THEN
       l_insert_new := TRUE;
  ELSE
       l_insert_new := FALSE;
  END IF;

     result := FND_FLEX_WORKFLOW.GENERATE(itemtype => 'ARSBALSG',
                                          itemkey => itemkey,
                                          insert_if_new => l_insert_new,
                                          ccid => x_return_ccid,
                                          concat_segs => x_concat_segs,
                                          concat_ids => x_concat_ids,
                                          concat_descrs => x_concat_descrs,
                                          error_message => X_ARERROR,
                                          new_combination => l_new_combination
					  );


   --arp_standard.debug('Return Ccid = ' || to_Char(X_return_ccid));

   IF X_return_ccid = -1 THEN
   -- This means new ccid has to be generated

     X_return_ccid := FND_FLEX_EXT.GET_CCID ( 'SQLGL'
                                      ,'GL#'
                                      ,X_ARFLEXNUM
                                      ,TO_CHAR(sysdate,'YYYY/MM/DD HH24:MI:SS')
                                      ,X_concat_segs
                                      );

     --arp_standard.debug('Return Ccid After GetCCid = ' || to_Char(X_return_ccid));

     IF X_return_ccid = 0 THEN
     -- error ocurred in flex package

       APP_EXCEPTION.RAISE_EXCEPTION;
     END IF;

   END IF;

   return result;

   --arp_standard.debug('AR_FLEXBUILDER_WF_PKG.SUBSTITUTE_BALANCING_SEGMENT (-) ');
EXCEPTION
  WHEN OTHERS THEN
    --arp_standard.debug('AR_FLEXBUILDER_WF_PKG.SUBSTITUTE_BALANCING_SEGMENT - Exception ' );
    RAISE;
END;
END;

/
