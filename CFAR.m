function [hits, output_treshold] = CFAR(inputSignal, numRefCells, numGapCells, bias)
    arguments
        inputSignal (1,:) double % must be a row vector
        numRefCells  int64         % Number of reference cells on one side of the cell under test
        numGapCells  int64         % Number of gap cells on one side of the cell under test
        bias  double {mustBePositive}
    end

    
    function threshold = CUTThres(CUTindex)
        % compute the raw threshold for a cell under test (CUT) (without the bias)
        threshold = (sum(inputSignal(CUTindex-numGapCells-numRefCells: CUTindex-numGapCells-1)) ...
                    + sum(inputSignal(CUTindex+numGapCells+1: CUTindex+numGapCells+numRefCells)))/(2*double(numRefCells));
    end

    output_treshold = bias + arrayfun(@CUTThres, (numGapCells+numRefCells+1:length(inputSignal)-numGapCells-numRefCells));
    
    function hit = IsHit(treshold_index)
        hit = 0;
        if inputSignal(treshold_index + numGapCells+numRefCells+1) >= output_treshold(treshold_index)
            hit = 1;
        end
    end

    hits = arrayfun(@IsHit, 1:length(output_treshold));

    % add padding to to each side of both output vectors
    hits = [zeros(1,numGapCells+numRefCells), hits, zeros(1,numGapCells+numRefCells)];
    output_treshold = [zeros(1,numGapCells+numRefCells), output_treshold, zeros(1,numGapCells+numRefCells)];
end