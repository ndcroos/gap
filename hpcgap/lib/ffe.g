#############################################################################
##
#W  ffe.g                        GAP library                    Thomas Breuer
#W                                                             & Frank Celler
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file deals with internal finite field elements.
##


#############################################################################
##

#V  MAXSIZE_GF_INTERNAL . . . . . . . . . . . . maximal size of internal ffes
##
BIND_GLOBAL( "MAXSIZE_GF_INTERNAL", 2^16 );


#############################################################################
##
#V  TYPES_FFE . . . . . . . . . . . . .  list of known types of internal ffes
##
#T TYPES_FFE := WeakPointerObj( [] );
BIND_GLOBAL( "TYPES_FFE", [] );
ShareSpecialObj( TYPES_FFE );
BIND_GLOBAL( "TYPES_FFE0", [] );
ShareSpecialObj( TYPES_FFE0 );

#############################################################################
##
#F  TYPE_FFE( <p> ) . . . . . . . . . . . type of a ffe in characteristic <p>
##
##  <p> must be a small prime integer
##  (see also `ffe.gi').
##
##  Note that the `One' and `Zero' values of the family cannot be set
##  in `TYPE_FFE' since this would need access to `One( Z(<p>) )' and
##  `Zero( Z(<p>) )', respectively,
##  which in turn would call `TYPE_FFE' and thus would lead to an infinite
##  recursion.
##
BIND_GLOBAL( "TYPE_FFE", function ( p )
    local type, fam;
    atomic readonly TYPES_FFE do
      if IsBound( TYPES_FFE[p] ) then
        return TYPES_FFE[p];
      fi;
    od;
#T     if IsBoundElmWPObj( TYPES_FFE, p ) then
#T       type:= ElmWPObj( TYPES_FFE, p );
#T       if type <> fail then
#T         return type;
#T       fi;
#T     fi;
    fam:= NewFamily( "FFEFamily", IS_FFE, 
                     CanEasilySortElements, CanEasilySortElements );
    SetIsUFDFamily( fam, true );
    SetCharacteristic( fam, p );
    type:= NewType( fam, IS_FFE and IsInternalRep and HasDegreeFFE);
    atomic readwrite TYPES_FFE do
      if IsBound( TYPES_FFE[p] ) then
        return TYPES_FFE[p];
      fi;    
      TYPES_FFE[p]:= type;
#T    SetElmWPObj( TYPES_FFE, p, type );
      return type;
    od;  
end );


#############################################################################
##
#F  TYPE_FFE0( <p> ) . . . . . . . . .type of zero ffe in characteristic <p>
##
##  see also "ffe.gi"
##
BIND_GLOBAL( "TYPE_FFE0", function ( p )
    local type, fam;
    atomic readonly TYPES_FFE0 do
      if IsBound( TYPES_FFE0[p] ) then
        return TYPES_FFE0[p];
      fi;
    od;
#T     if IsBoundElmWPObj( TYPES_FFE, p ) then
#T       type:= ElmWPObj( TYPES_FFE, p );
#T       if type <> fail then
#T         return type;
#T       fi;
#T     fi;
    fam:= FamilyType(TYPE_FFE(p));
    type:= NewType( fam, IS_FFE and IsInternalRep and IsZero and HasIsZero 
                   and HasDegreeFFE );
    atomic readwrite TYPES_FFE0 do
      if IsBound( TYPES_FFE0[p] ) then
        return TYPES_FFE0[p];
      fi;  
      TYPES_FFE0[p]:= type;
#T    SetElmWPObj( TYPES_FFE, p, type );
      return type;
    od;  
end );


#############################################################################
##
#m  DegreeFEE( <ffe> )  . . . . . . . . . . . . . . . . . .  for internal ffe
##
InstallMethod( DegreeFFE,
    "for internal FFE",
    true,
    [ IsFFE and IsInternalRep ], 0,
    DEGREE_FFE_DEFAULT );

#############################################################################
##
#m  Characteristic( <ffe> )   . . . . . . . . . . . . . . .  for internal ffe
##
InstallMethod( Characteristic,
    "for internal FFE",
    true,
    [ IsFFE and IsInternalRep ], 0,
    CHAR_FFE_DEFAULT );


#############################################################################
##
#M  LogFFE( <ffe>, <ffe> )  . . . . . . . . . . . . . . . .  for internal ffe
##
InstallMethod( LogFFE,
    "for two internal FFEs",
    IsIdenticalObj,
    [ IsFFE and IsInternalRep, IsFFE and IsInternalRep ], 0,
    LOG_FFE_DEFAULT );


#############################################################################
##
#M  IntFFE( <ffe> ) . . . . . . . . . . . . . . . . . . . .  for internal ffe
##
InstallMethod( IntFFE,
    "for internal FFE",
    true,
    [ IsFFE and IsInternalRep ], 0,
    INT_FFE_DEFAULT );


#############################################################################
##
#m  \*( <ffe>, <int> )  . . . . . . . . . . . . . for ffe and (large) integer
##
##  Note that the multiplication of internally represented FFEs with small
##  integers is handled by the kernel.
##
InstallOtherMethod( \*,
    "internal ffe * (large) integer",
    true,
    [ IsFFE and IsInternalRep, IsInt ], 0,
    function( ffe, int )
    local char;
    char:= Characteristic( ffe );
    if IsSmallIntRep( char ) then
      return ffe * ( int mod char );
    else
      return PROD_INT_OBJ( int, ffe );
    fi;
end );
        

#############################################################################
##
#O  SUM_FFE_LARGE
#O  DIFF_FFE_LARGE
#O  PROD_FFE_LARGE
#O  QUO_FFE_LARGE
#O  LOG_FFE_LARGE
##
##  If the {\GAP} kernel cannot handle the addition, multiplication etc.
##  of internally represented FFEs then it delegates to the library without
##  checking the characteristic; therefore this check must be done here.
##  (Note that `LogFFE' is an operation for which the kernel does not know
##  a table of methods, so the check for equal characteristic is done by
##  the method selection.
#T  Note that `LogFFEHandler' would not need to call `LOG_FFE_DEFAULT';
#T  if the two arguments <z>, <r> are represented w.r.t. incompatible fields
#T  then either <z> can be represented in the field of <r> or the logarithm
#T  does not exist.
##
    
DeclareOperation("SUM_FFE_LARGE", [IsFFE and IsInternalRep,
        IsFFE and IsInternalRep]);

InstallOtherMethod(SUM_FFE_LARGE,  [IsFFE,
        IsFFE],
        function( x, y )
    if Characteristic( x ) <> Characteristic( y ) then
      Error( "<x> and <y> have different characteristic" );
  fi;
  TryNextMethod();
end);

DeclareOperation("DIFF_FFE_LARGE", [IsFFE and IsInternalRep,
        IsFFE and IsInternalRep]);

InstallOtherMethod(DIFF_FFE_LARGE,  [IsFFE,
        IsFFE],
        function( x, y )
    if Characteristic( x ) <> Characteristic( y ) then
      Error( "<x> and <y> have different characteristic" );
  fi;
  TryNextMethod();
end);

DeclareOperation("PROD_FFE_LARGE", [IsFFE and IsInternalRep,
        IsFFE and IsInternalRep]);

InstallOtherMethod(PROD_FFE_LARGE,  [IsFFE,
        IsFFE ],
        function( x, y )
    if Characteristic( x ) <> Characteristic( y ) then
      Error( "<x> and <y> have different characteristic" );
  fi;
  TryNextMethod();
end);

DeclareOperation("QUO_FFE_LARGE", [IsFFE,
        IsFFE]);

InstallOtherMethod(QUO_FFE_LARGE,  [IsFFE and IsInternalRep,
        IsFFE and IsInternalRep],
        function( x, y )
    if Characteristic( x ) <> Characteristic( y ) then
      Error( "<x> and <y> have different characteristic" );
  fi;
  TryNextMethod();
end);


BIND_GLOBAL( "LOG_FFE_LARGE", function( x, y )
    Error( "not supported yet -- this should never happen" );
end );

#############################################################################
##
#O  ZOp -- operation to compute Z for large values of q
##

DeclareOperation("ZOp", [IsPosInt]);

#############################################################################
##

#E

