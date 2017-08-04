% Read a line and parse it. Make sure the entire line is read.
function [C, fid] = arTextScan( fid, varargin )

    tmp = ''; C{1} = {};
    if ( isstruct( fid ) )
        % If we are passed a struct, then it is a string with position
        % (parsing from text)
        while ( (fid.pos < numel( fid.str ))&&(isempty(tmp)||isempty(C{1})) )
            % Find next newline
            newlines = regexp(fid.str, '\n|\r\n|\r');
            nl = newlines( find( newlines > fid.pos, 1 ) );
            if ( isempty( nl ) )
                nl = numel( fid.str );
            end
            
            % Grab string and advance position
            tmp = fid.str( fid.pos : nl );
            fid.pos = nl + 1;

            C = textscan(tmp, varargin{:} );
        end
    else
        % If we are passed a file handle, it is business as usual
        while ~feof(fid)&&(isempty(tmp)||isempty(C{1}))
            tmp = fgets(fid);

            C = textscan(tmp, varargin{:} );
        end
    end
    
    if ~isempty(tmp)
        C = textscan(tmp, varargin{:} );
    else
        C = textscan(' ', varargin{:} );
    end
    
end