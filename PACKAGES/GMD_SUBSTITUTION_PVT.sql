--------------------------------------------------------
--  DDL for Package GMD_SUBSTITUTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_SUBSTITUTION_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVSUBS.pls 120.0.12000000.1 2007/01/31 16:17:05 appldev noship $ */

  m_api_version   CONSTANT NUMBER         := 1;
  m_pkg_name      CONSTANT VARCHAR2 (30)  := 'GMD_SUBSTITUTION_PVT';

  -- Creation of substitution header
  PROCEDURE Create_substitution_header
  ( p_substitution_id      IN  gmd_item_substitution_hdr.substitution_id%TYPE
  , p_substitution_hdr_rec IN  gmd_substitution_pub.gmd_substitution_hdr_rec_type
  , x_message_count        OUT NOCOPY  NUMBER
  , x_message_list         OUT NOCOPY  VARCHAR2
  , x_return_status        OUT NOCOPY  VARCHAR2
  );

  -- Creation of substitution detail
  PROCEDURE Create_substitution_detail
  ( p_substitution_line_id IN  gmd_item_substitution_dtl.substitution_line_id%TYPE
  , p_substitution_id      IN  gmd_item_substitution_dtl.substitution_id%TYPE
  , p_substitution_dtl_rec IN  gmd_substitution_pub.gmd_substitution_dtl_rec_type
  , x_message_count        OUT NOCOPY  NUMBER
  , x_message_list         OUT NOCOPY  VARCHAR2
  , x_return_status        OUT NOCOPY  VARCHAR2
  );

  -- Creation of formula association
  PROCEDURE Create_formula_association
  ( p_substitution_id           IN  gmd_formula_substitution.substitution_id%TYPE
  , p_formula_substitution_tbl  IN  gmd_substitution_pub.gmd_formula_substitution_tab
  , x_message_count             OUT NOCOPY  NUMBER
  , x_message_list              OUT NOCOPY  VARCHAR2
  , x_return_status             OUT NOCOPY  VARCHAR2
  );

  -- Update of substitution header
  PROCEDURE Update_substitution_header
  ( p_substitution_hdr_rec IN          gmd_item_substitution_hdr%ROWTYPE
  , x_message_count        OUT NOCOPY  NUMBER
  , x_message_list         OUT NOCOPY  VARCHAR2
  , x_return_status        OUT NOCOPY  VARCHAR2
  );

  -- Update of substitution lines
  PROCEDURE Update_substitution_detail
  ( p_substitution_dtl_rec  IN          gmd_item_substitution_dtl%ROWTYPE
  , x_message_count         OUT NOCOPY  NUMBER
  , x_message_list          OUT NOCOPY  VARCHAR2
  , x_return_status         OUT NOCOPY  VARCHAR2
  );

  -- Deletion of formula association
  PROCEDURE Delete_formula_association
  ( p_formula_substitution_id  IN          NUMBER
  , x_message_count            OUT NOCOPY  NUMBER
  , x_message_list             OUT NOCOPY  VARCHAR2
  , x_return_status            OUT NOCOPY  VARCHAR2
  );

  -- Deletion of formula association
  PROCEDURE Copy_substitution
  ( p_old_substitution_id      IN          NUMBER
  , x_new_substitution_version OUT NOCOPY  NUMBER
  , x_message_count            OUT NOCOPY  NUMBER
  , x_message_list             OUT NOCOPY  VARCHAR2
  , x_return_status            OUT NOCOPY  VARCHAR2
  );

END GMD_SUBSTITUTION_PVT;

 

/
