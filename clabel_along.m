function h = clabel_along( c, x, y, varargin )
%CLABEL_ALONG Label contours along a curve
%   H = CLABEL_ALONG( C, X, Y ) labels all contours in C, placing labels
%   at the intersections between the contours and the curve in X, Y.
%   Labels are rotated to align with the contour.
%
%   H = CLABEL_ALONG( C, X, Y, V ) as above, but only labels the contours
%   with levels contained in vector V.  If V is empty (default), then all
%   contours are labeled.
%
%   H = CLABEL_ALONG( C, X, Y, V, ROTATE ) as above, but ROTATE is a
%   boolean flag to enable label rotation.  If ROTATE is TRUE (default),
%   then the labels are rotated.  The rotation angle is based on the slope
%   of the contour at the intersection point and is corrected for the
%   aspect ratio of the data and the plot.
%
%   If the data or plot aspect ratios change significantly after the call
%   to CLABEL_ALONG, the labels may not look properly aligned.
%
%   The graphics handles for all of the labels are returned in H.
%
%   CLABEL_ALONG requires Douglas Schwarz's INTERSECTIONS routine to
%   calculate the intersectinos between the curve and the contours.  It is
%   available from the Matlab File Exchange
%       https://www.mathworks.com/matlabcentral/fileexchange/11837
%
%   Example:
%       [c, h] = contour( peaks );
%       CLABEL_ALONG( c, [1 37], [40 1] );
%       CLABEL_ALONG( c, [25 25], [37.5 30] );
%       CLABEL_ALONG( c, [27.5 27.5], [27 25] );
%
%   See also CONTOUR, CONTOURF, CONTOURC, CLABEL, INTERSECTIONS, DASPECT, PBASPECT.

%   Rob McDonald
%   rob.a.mcdonald@gmail.com
%   25 March    2021 v. 1.0 -- Original version.

if ( ~exist( 'intersections', 'file' ) )
    error( 'clabel_along:intersections_not_found',...
        'clabel_along could not find intersections.\nIt is available from the MATLAB file exchange:\nhttps://www.mathworks.com/matlabcentral/fileexchange/11837' );
end

% Handle values of contours to label.  Empty for all (default).
if ( nargin < 4 )
    v = [];
else
    v = varargin{1};
end

% Handle rotation disabling flag.  True to rotate (default).
if ( nargin < 5 )
    rotate = true;
else
    rotate = varargin{2};
end

% Grab aspect ratios to correct rotation
% Data aspect ratio
da = daspect();
ard = da(2) / da(1);
% Plot aspect ratio
pa = pbaspect();
arp = pa(2) / pa(1);

% Initialize handle array
h = [];

% Loop over contours in c array
nlimit = size( c , 2 );
icont = 1;
while( icont < nlimit )

    % Pull out contour level and number of points in this contour line
    level = c( 1, icont );
    n = c( 2, icont );

    % Only proceed for empty v (all) or contour in v
    if ( isempty( v ) || any( level == v ) )

        % Pick off contour points
        xc = c( 1, icont+1:icont+n );
        yc = c( 2, icont+1:icont+n );

        % Calculate the intersection points between the contours and the
        % guide curve using Douglas Schwarz's routine
        % https://www.mathworks.com/matlabcentral/fileexchange/11837
        [ xint, yint, iout ] = intersections( xc, yc, x, y );

        % Loop over all intersections
        nint = length( xint );
        for iint = 1:nint
            th = 0;
            if ( rotate )
                % Calculate text rotation angle based on curve slope and
                % plot and data aspect ratios.
                iprev = floor( iout( iint ) );
                if ( iprev == length(xc) )
                    iprev = iprev - 1;
                end
                inext = iprev + 1;

                % Calculate aspect ratio adjusted slope
                dx = ( xc( inext ) - xc( iprev ) );
                dy = sign(dx) * ( yc( inext ) - yc( iprev ) ) / ard * arp;
                dx = sign(dx) * dx;

                % Calculate angle
                th = atan2( dy, dx ) * 180.0 / pi;
            end

            hh = text( xint(iint), yint(iint), num2str( level ), 'rotation', th, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle'  );

            % Append text handle
            h = [h hh];
        end
    end

    % Increment to next contour line
    icont = icont + n + 1;
end
