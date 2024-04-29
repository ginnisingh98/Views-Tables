--------------------------------------------------------
--  DDL for Package Body OKL_INV_TYPE_DELETE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INV_TYPE_DELETE_PVT" AS
/* $Header: OKLRITDB.pls 115.3 2002/02/12 14:31:17 pkm ship        $ */
  ---------------------------------------------------------------------------
  -- GLOBAL DATASTRUCTURES
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

PROCEDURE delete_type(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ity_del_rec                  IN ity_del_rec_type)
IS

   CURSOR inv_line_type_csr (p_ity_id  NUMBER) IS
   		  SELECT id
		  FROM okl_invc_line_types_v
		  WHERE ity_id = p_ity_id;

   CURSOR inv_format_strms_csr (p_ilt_id  NUMBER) IS
		  SELECT id
		  FROM okl_invc_frmt_strms_v
		  WHERE ilt_id = p_ilt_id;

p_infv_rec			  	  			 Okl_Inf_Pvt.infv_rec_type;
p_ityv_rec			  				 Okl_Ity_Pvt.ityv_rec_type;
p_iltv_rec							 Okl_Ilt_Pvt.iltv_rec_type;
p_ilsv_rec							 Okl_Ils_Pvt.ilsv_rec_type;


p_infv_tbl			  	  			 Okl_Inf_Pvt.infv_tbl_type;
p_ityv_tbl			  				 Okl_Ity_Pvt.ityv_tbl_type;
p_iltv_tbl							 Okl_Ilt_Pvt.iltv_tbl_type;
p_ilsv_tbl							 Okl_Ils_Pvt.ilsv_tbl_type;

BEGIN

-- The delete routine works its way up the ER hierarchy
--

  FOR inv_line_type IN inv_line_type_csr ( p_ity_del_rec.id ) LOOP

  	  FOR inv_format_strms IN inv_format_strms_csr( inv_line_type.id ) LOOP
	      p_ilsv_rec.id := inv_format_strms.id;
  	  	  Okl_Ils_Pvt.delete_row(
      			p_api_version,
    			p_init_msg_list,
    			x_return_status,
    			x_msg_count,
    			x_msg_data,
    			p_ilsv_rec);
	  END LOOP;

      p_iltv_rec.id := inv_line_type.id;
  	  Okl_Ilt_Pvt.delete_row(
      		p_api_version,
    		p_init_msg_list,
    		x_return_status,
    		x_msg_count,
    		x_msg_data,
    		p_iltv_rec);
  END LOOP;

  p_ityv_rec.id := p_ity_del_rec.id;
  Okl_Ity_Pvt.delete_row(
        p_api_version,
    	p_init_msg_list,
    	x_return_status,
    	x_msg_count,
    	x_msg_data,
    	p_ityv_rec);


EXCEPTION
	 WHEN OTHERS THEN
                  null;
END;

PROCEDURE delete_type(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT Okl_Api.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ity_del_tbl                  IN ity_del_tbl_type)
IS

p_ity_del_rec						  ity_del_rec_type;

BEGIN
	 FOR i IN  p_ity_del_tbl.first..p_ity_del_tbl.COUNT LOOP
	 	 p_ity_del_rec := p_ity_del_tbl(i);

	 	 delete_type(
     		  p_api_version,
    		  p_init_msg_list,
    		  x_return_status,
    		  x_msg_count,
    		  x_msg_data,
    		  p_ity_del_rec);
	 END LOOP;
EXCEPTION
	 WHEN OTHERS THEN
                  null;
END;

END Okl_Inv_Type_Delete_Pvt;

/
