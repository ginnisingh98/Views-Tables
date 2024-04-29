--------------------------------------------------------
--  DDL for Package Body GMD_DISP_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_DISP_GRP" AS
 /* $Header: GMDGDISB.pls 120.0.12010000.1 2009/03/31 18:24:43 rnalla noship $ */

-- Start of comments
--+==========================================================================+
--|                   Copyright (c) 1998 Oracle Corporation                  |
--|                          Redwood Shores, CA, USA                         |
--|                            All rights reserved.                          |
--+==========================================================================+
--| File Name          : GMDGDISB.pls                                        |
--| Package Name       : GMD_DISP_GRP                                        |
--| Type               : Group                                               |
--|                                                                          |
--| Notes                                                                    |
--|    This package contains Group layer APIs for Changing the disposition   |
--|    of a Sample/Group                                                     |
--|                                                                          |
--| HISTORY                                                                  |
--|     Ravi Lingappa Nagaraja    16-Jun-2008     Created.                   |
--+==========================================================================+
-- End of comments


-- To change the disposition of a sample if Sample_id is provided.
PROCEDURE update_sample_comp_disp
(
  p_update_disp_rec	        IN Gmd_Samples_Grp.update_disp_rec
, p_to_disposition		IN         VARCHAR2
, x_return_status 		OUT NOCOPY VARCHAR2
, x_message_data		OUT NOCOPY VARCHAR2
) IS

   l_return_status   	VARCHAR2(1);
   l_message_data    	VARCHAR2(2000);


 BEGIN
  x_return_status        := FND_API.G_RET_STS_SUCCESS;
    Gmd_Samples_Grp.update_sample_comp_disp
		( p_update_disp_rec => p_update_disp_rec
		, p_to_disposition =>  p_to_disposition
		, x_return_status  =>  l_return_status
		, x_message_data   =>  l_message_data );
    IF (l_return_status <> 'S') THEN
       x_message_data := l_message_data;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END;

PROCEDURE update_lot_grade_batch
(
  p_sample_id			IN         NUMBER DEFAULT NULL
, p_composite_spec_disp_id  	IN         NUMBER DEFAULT NULL
, p_to_lot_status_id	  	IN         NUMBER
, p_from_lot_status_id	  	IN         NUMBER
, p_to_grade_code		IN         VARCHAR2
, p_from_grade_code		IN         VARCHAR2 DEFAULT NULL
, p_to_qc_status		IN         NUMBER
, p_reason_id			IN         NUMBER
, p_hold_date                   IN         DATE DEFAULT SYSDATE
, x_return_status 		OUT NOCOPY VARCHAR2
, x_message_data		OUT NOCOPY VARCHAR2
) IS

   l_return_status   	VARCHAR2(1);
   l_message_data    	VARCHAR2(2000);

BEGIN
    x_return_status        := FND_API.G_RET_STS_SUCCESS;
    Gmd_Samples_Grp.update_lot_grade_batch(
    	     p_sample_id              => p_sample_id
	   , p_composite_spec_disp_id => p_composite_spec_disp_id
	   , p_to_lot_status_id       => p_to_lot_status_id
	   , p_from_lot_status_id     => p_from_lot_status_id
	   , p_to_grade_code	      => p_to_grade_code
	   , p_from_grade_code	      => p_from_grade_code
	   , p_to_qc_status	      => p_to_qc_status
	   , p_reason_id	      => p_reason_id
	   , p_hold_date              => p_hold_date
	   , x_return_status 	      => l_return_status
	   , x_message_data	      => l_message_data );
    IF (l_return_status <> 'S') THEN
       x_message_data := l_message_data;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END;


END gmd_disp_grp;

/
