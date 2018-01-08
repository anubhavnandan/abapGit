class ZCL_ABAPGIT_XML_INPUT definition
  public
  inheriting from ZCL_ABAPGIT_XML
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !IV_XML type CLIKE
    raising
      ZCX_ABAPGIT_EXCEPTION .
  methods READ
    importing
      !IV_NAME type CLIKE
    changing
      !CG_DATA type ANY
    raising
      ZCX_ABAPGIT_EXCEPTION .
  methods GET_RAW
    returning
      value(RI_RAW) type ref to IF_IXML_DOCUMENT .
* todo, add read_xml to match add_xml in lcl_xml_output
  methods GET_METADATA
    returning
      value(RS_METADATA) type ZIF_ABAPGIT_DEFINITIONS=>TY_METADATA .
  PRIVATE SECTION.
    METHODS: fix_xml.

ENDCLASS.



CLASS ZCL_ABAPGIT_XML_INPUT IMPLEMENTATION.


  METHOD constructor.

    super->constructor( ).
    parse( iv_xml ).
    fix_xml( ).

  ENDMETHOD.                    "constructor


  METHOD fix_xml.

    DATA: li_git  TYPE REF TO if_ixml_element,
          li_abap TYPE REF TO if_ixml_node.


    li_git ?= mi_xml_doc->find_from_name_ns( depth = 0 name = c_abapgit_tag ).
    li_abap = li_git->get_first_child( ).

    mi_xml_doc->get_root( )->remove_child( li_git ).
    mi_xml_doc->get_root( )->append_child( li_abap ).

  ENDMETHOD.                    "fix_xml


  METHOD get_metadata.
    rs_metadata = ms_metadata.
  ENDMETHOD.                    "get_metadata


  METHOD get_raw.
    ri_raw = mi_xml_doc.
  ENDMETHOD.                    "get_raw


  METHOD read.

    DATA: lx_error TYPE REF TO cx_transformation_error,
          lt_rtab  TYPE abap_trans_resbind_tab.

    FIELD-SYMBOLS: <ls_rtab> LIKE LINE OF lt_rtab.

    ASSERT NOT iv_name IS INITIAL.

    CLEAR cg_data. "Initialize result to avoid problems with empty values

    APPEND INITIAL LINE TO lt_rtab ASSIGNING <ls_rtab>.
    <ls_rtab>-name = iv_name.
    GET REFERENCE OF cg_data INTO <ls_rtab>-value.

    TRY.
        CALL TRANSFORMATION id
          OPTIONS value_handling = 'accept_data_loss'
          SOURCE XML mi_xml_doc
          RESULT (lt_rtab) ##no_text.
      CATCH cx_transformation_error INTO lx_error.
        zcx_abapgit_exception=>raise( lx_error->if_message~get_text( ) ).
    ENDTRY.

  ENDMETHOD.                    "read
ENDCLASS.
